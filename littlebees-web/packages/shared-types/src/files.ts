import { FilePurpose } from './enums';

export interface FileResponse {
  id: string;
  filename: string;
  mimeType: string;
  sizeBytes: number;
  purpose: FilePurpose;
  url: string;
  createdAt: string;
}

export interface UploadFileRequest {
  purpose: FilePurpose;
}

export interface PresignedUrlResponse {
  uploadUrl: string;
  fileId: string;
  expiresAt: string;
}
