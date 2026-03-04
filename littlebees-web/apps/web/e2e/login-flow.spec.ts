import { test, expect } from '@playwright/test';

test.describe('Login → Dashboard flow', () => {

  test('Login page loads correctly', async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');

    // Screenshot of login page
    await page.screenshot({ path: 'e2e/screenshots/01-login-page.png', fullPage: true });

    // Check login form is visible
    const heading = page.locator('h1');
    await expect(heading).toContainText('KinderSpace');

    const emailInput = page.locator('input[name="email"]');
    await expect(emailInput).toBeVisible();

    const passwordInput = page.locator('input[name="password"]');
    await expect(passwordInput).toBeVisible();

    const submitButton = page.locator('button[type="submit"]');
    await expect(submitButton).toBeVisible();
    await expect(submitButton).toContainText('Iniciar Sesión');
  });

  test('Dev user selector fills credentials', async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');

    // Click first dev user button (María González - Directora)
    const devUserButton = page.locator('button:has-text("María González")');
    if (await devUserButton.isVisible()) {
      await devUserButton.click();
      await page.screenshot({ path: 'e2e/screenshots/02-after-dev-user-click.png', fullPage: true });

      const emailInput = page.locator('input[name="email"]');
      await expect(emailInput).toHaveValue('director@petitsoleil.mx');
    }
  });

  test('Full login flow with network inspection', async ({ page }) => {
    // Collect all network requests and responses
    const networkLog: string[] = [];
    page.on('request', req => {
      if (!req.url().includes('_next') && !req.url().includes('fonts.googleapis')) {
        networkLog.push(`→ ${req.method()} ${req.url()}`);
      }
    });
    page.on('response', res => {
      if (!res.url().includes('_next') && !res.url().includes('fonts.googleapis')) {
        networkLog.push(`← ${res.status()} ${res.url()}`);
      }
    });

    // Collect console messages
    const consoleLogs: string[] = [];
    page.on('console', msg => {
      consoleLogs.push(`[${msg.type()}] ${msg.text()}`);
    });

    // Collect page errors
    const pageErrors: string[] = [];
    page.on('pageerror', err => {
      pageErrors.push(err.message);
    });

    // Step 1: Go to login
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await page.screenshot({ path: 'e2e/screenshots/03-login-before.png', fullPage: true });

    // Step 2: Fill credentials
    await page.fill('input[name="email"]', 'director@petitsoleil.mx');
    await page.fill('input[name="password"]', 'Password123!');
    await page.screenshot({ path: 'e2e/screenshots/04-login-filled.png', fullPage: true });

    // Step 3: Click login and wait for navigation
    await page.click('button[type="submit"]');

    // Wait for navigation or error
    await page.waitForTimeout(5000);
    await page.screenshot({ path: 'e2e/screenshots/05-after-login.png', fullPage: true });

    // Step 4: Check current URL
    const currentUrl = page.url();

    // Step 5: Get page content to debug
    const bodyHTML = await page.evaluate(() => {
      return document.body.innerHTML.substring(0, 2000);
    });

    // Step 6: Check cookies
    const cookies = await page.context().cookies();
    const tokenCookies = cookies.filter(c => c.name.includes('token') || c.name.includes('access'));

    // Step 7: Wait more and take final screenshot
    await page.waitForTimeout(3000);
    await page.screenshot({ path: 'e2e/screenshots/06-final-state.png', fullPage: true });

    // Print debug info
    console.log('\n=== DEBUG INFO ===');
    console.log('Current URL:', currentUrl);
    console.log('\n--- Cookies ---');
    tokenCookies.forEach(c => console.log(`  ${c.name} = ${c.value.substring(0, 30)}...`));
    console.log('\n--- Network Log ---');
    networkLog.forEach(l => console.log(`  ${l}`));
    console.log('\n--- Console Logs ---');
    consoleLogs.forEach(l => console.log(`  ${l}`));
    console.log('\n--- Page Errors ---');
    pageErrors.forEach(e => console.log(`  ${e}`));
    console.log('\n--- Body HTML (first 2000 chars) ---');
    console.log(bodyHTML);
    console.log('=== END DEBUG ===\n');
  });
});
