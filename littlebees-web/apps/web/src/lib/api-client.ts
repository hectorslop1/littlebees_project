import { getAccessToken, getRefreshToken, storeTokens, clearTokens } from './auth';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3002/api/v1';

export interface ApiError {
  statusCode: number;
  message: string;
  error?: string;
  details?: Record<string, string[]>;
}

class ApiClientClass {
  private baseUrl: string;
  private refreshPromise: Promise<boolean> | null = null;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  async get<T>(endpoint: string, params?: Record<string, string | number | boolean | undefined>): Promise<T> {
    const url = params ? `${endpoint}?${this.serializeParams(params)}` : endpoint;
    return this.request<T>(url);
  }

  async post<T>(endpoint: string, body?: unknown): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  async patch<T>(endpoint: string, body?: unknown): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PATCH',
      body: body ? JSON.stringify(body) : undefined,
    });
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }

  async upload<T>(endpoint: string, formData: FormData): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: formData,
      isFormData: true,
    });
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit & { isFormData?: boolean } = {},
  ): Promise<T> {
    const { isFormData, ...fetchOptions } = options;
    const headers: Record<string, string> = {};

    if (!isFormData) {
      headers['Content-Type'] = 'application/json';
    }

    const token = getAccessToken();
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...fetchOptions,
      headers: { ...headers, ...(fetchOptions.headers as Record<string, string>) },
    });

    if (response.status === 401 && token) {
      const refreshed = await this.tryRefreshToken();
      if (refreshed) {
        const newToken = getAccessToken();
        headers['Authorization'] = `Bearer ${newToken}`;
        const retryResponse = await fetch(`${this.baseUrl}${endpoint}`, {
          ...fetchOptions,
          headers: { ...headers, ...(fetchOptions.headers as Record<string, string>) },
        });
        if (!retryResponse.ok) {
          throw await this.parseError(retryResponse);
        }
        if (retryResponse.status === 204) return undefined as T;
        return retryResponse.json();
      }
      clearTokens();
      if (typeof window !== 'undefined') {
        window.location.href = '/login';
      }
      throw new Error('Sesión expirada');
    }

    if (!response.ok) {
      throw await this.parseError(response);
    }

    if (response.status === 204) return undefined as T;
    return response.json();
  }

  private async tryRefreshToken(): Promise<boolean> {
    if (this.refreshPromise) return this.refreshPromise;

    this.refreshPromise = (async () => {
      try {
        const refreshToken = getRefreshToken();
        if (!refreshToken) return false;

        const response = await fetch(`${this.baseUrl}/auth/refresh`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ refreshToken }),
        });

        if (!response.ok) return false;

        const data = await response.json();
        storeTokens(data.accessToken, data.refreshToken);
        return true;
      } catch {
        return false;
      } finally {
        this.refreshPromise = null;
      }
    })();

    return this.refreshPromise;
  }

  private async parseError(response: Response): Promise<ApiError> {
    try {
      const body = await response.json();
      return {
        statusCode: response.status,
        message: body.message || `Error ${response.status}`,
        error: body.error,
        details: body.details,
      };
    } catch {
      return {
        statusCode: response.status,
        message: 'Error de conexión',
      };
    }
  }

  private serializeParams(params: Record<string, string | number | boolean | undefined>): string {
    const entries = Object.entries(params).filter(([, v]) => v !== undefined && v !== '');
    return new URLSearchParams(entries.map(([k, v]) => [k, String(v)])).toString();
  }
}

export const api = new ApiClientClass(API_BASE_URL);
