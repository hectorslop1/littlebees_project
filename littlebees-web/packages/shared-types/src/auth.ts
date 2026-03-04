import { UserRole } from './enums';

export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: UserInfo;
  tenant: TenantInfo;
  mfaRequired?: boolean;
  tempToken?: string;
}

export interface MfaVerifyRequest {
  tempToken: string;
  code: string;
}

export interface RefreshTokenRequest {
  refreshToken: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phone?: string;
}

export interface UserInfo {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone: string | null;
  avatarUrl: string | null;
  role: UserRole;
  mfaEnabled: boolean;
}

export interface TenantInfo {
  id: string;
  name: string;
  slug: string;
  logoUrl: string | null;
}

export interface JwtPayload {
  sub: string; // user ID
  tid: string; // tenant ID
  role: UserRole;
  iat: number;
  exp: number;
  iss: string;
}
