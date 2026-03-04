import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30000,
  use: {
    baseURL: 'http://localhost:3003',
    screenshot: 'on',
    trace: 'on',
  },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
  ],
});
