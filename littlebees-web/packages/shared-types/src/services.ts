import { ServiceType } from './enums';

export interface ExtraServiceResponse {
  id: string;
  name: string;
  description: string | null;
  type: ServiceType;
  schedule: string | null;
  price: number;
  capacity: number | null;
  imageUrl: string | null;
  status: string;
  metadata: Record<string, unknown> | null;
  createdAt: string;
  updatedAt: string;
}

export interface CreateExtraServiceRequest {
  name: string;
  description?: string;
  type: ServiceType;
  schedule?: string;
  price: number;
  capacity?: number;
  imageUrl?: string;
}

export interface UpdateExtraServiceRequest {
  name?: string;
  description?: string;
  schedule?: string;
  price?: number;
  capacity?: number;
  imageUrl?: string;
  status?: string;
}
