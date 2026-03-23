'use client';

import { createContext, useCallback, useEffect, useState } from 'react';
import type { UserInfo, TenantInfo, LoginResponse } from '@kinderspace/shared-types';
import { UserRole } from '@kinderspace/shared-types';
import { api } from '@/lib/api-client';
import { storeTokens, clearTokens, getAccessToken, getRefreshToken, parseJwt } from '@/lib/auth';

export interface AuthContextType {
  user: UserInfo | null;
  tenant: TenantInfo | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  role: UserRole | null;
  isDirector: boolean;
  isAdmin: boolean;
  isTeacher: boolean;
  isParent: boolean;
  isStaff: boolean;
  login: (email: string, password: string) => Promise<LoginResponse>;
  logout: () => void;
  refreshSession: () => Promise<void>;
}

export const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<UserInfo | null>(null);
  const [tenant, setTenant] = useState<TenantInfo | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    const hydrateSession = async () => {
      const token = getAccessToken();
      const refreshToken = getRefreshToken();

      const applySession = async () => {
        const data = await api.get<{ user: UserInfo; tenant: TenantInfo }>('/auth/me');
        if (cancelled) return;
        setUser(data.user);
        setTenant(data.tenant);
      };

      try {
        if (token) {
          const payload = parseJwt(token);
          if (payload && payload.exp * 1000 > Date.now()) {
            await applySession();
            return;
          }
        }

        if (refreshToken) {
          const refreshed = await api.post<LoginResponse>('/auth/refresh', { refreshToken });
          if (cancelled) return;
          storeTokens(refreshed.accessToken, refreshed.refreshToken);
          setUser(refreshed.user);
          setTenant(refreshed.tenant);
          return;
        }

        clearTokens();
      } catch {
        clearTokens();
        if (!cancelled) {
          setUser(null);
          setTenant(null);
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false);
        }
      }
    };

    hydrateSession();

    return () => {
      cancelled = true;
    };
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const data = await api.post<LoginResponse>('/auth/login', { email, password });
    storeTokens(data.accessToken, data.refreshToken);
    setUser(data.user);
    setTenant(data.tenant);
    return data;
  }, []);

  const logout = useCallback(() => {
    clearTokens();
    setUser(null);
    setTenant(null);
    window.location.href = '/login';
  }, []);

  const refreshSession = useCallback(async () => {
    const data = await api.get<{ user: UserInfo; tenant: TenantInfo }>('/auth/me');
    setUser(data.user);
    setTenant(data.tenant);
  }, []);

  const role = user?.role ?? null;
  const isDirector = role === UserRole.DIRECTOR;
  const isAdmin = role === UserRole.ADMIN || role === UserRole.SUPER_ADMIN;
  const isTeacher = role === UserRole.TEACHER;
  const isParent = role === UserRole.PARENT;
  const isStaff = isDirector || isAdmin || isTeacher;

  return (
    <AuthContext.Provider
      value={{
        user,
        tenant,
        isLoading,
        isAuthenticated: !!user,
        role,
        isDirector,
        isAdmin,
        isTeacher,
        isParent,
        isStaff,
        login,
        logout,
        refreshSession,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}
