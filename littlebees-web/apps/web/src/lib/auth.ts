import type { UserInfo, TenantInfo, JwtPayload } from '@kinderspace/shared-types';

const ACCESS_TOKEN_KEY = 'access_token';
const REFRESH_TOKEN_KEY = 'refresh_token';

export function storeTokens(accessToken: string, refreshToken: string) {
  document.cookie = `${ACCESS_TOKEN_KEY}=${accessToken}; path=/; SameSite=Strict; max-age=900`;
  document.cookie = `${REFRESH_TOKEN_KEY}=${refreshToken}; path=/; SameSite=Strict; max-age=604800`;
}

export function clearTokens() {
  document.cookie = `${ACCESS_TOKEN_KEY}=; path=/; max-age=0`;
  document.cookie = `${REFRESH_TOKEN_KEY}=; path=/; max-age=0`;
}

export function getAccessToken(): string | null {
  return getCookie(ACCESS_TOKEN_KEY);
}

export function getRefreshToken(): string | null {
  return getCookie(REFRESH_TOKEN_KEY);
}

function getCookie(name: string): string | null {
  if (typeof document === 'undefined') return null;
  const match = document.cookie.match(new RegExp(`(?:^|; )${name}=([^;]*)`));
  return match ? decodeURIComponent(match[1]) : null;
}

export function parseJwt(token: string): JwtPayload | null {
  try {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const json = decodeURIComponent(
      atob(base64)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join(''),
    );
    return JSON.parse(json);
  } catch {
    return null;
  }
}

export function isTokenExpired(token: string): boolean {
  const payload = parseJwt(token);
  if (!payload) return true;
  return Date.now() >= payload.exp * 1000;
}

export function extractUserFromToken(token: string): { user: Partial<UserInfo>; tenantId: string } | null {
  const payload = parseJwt(token);
  if (!payload) return null;
  return {
    user: { id: payload.sub, role: payload.role },
    tenantId: payload.tid,
  };
}
