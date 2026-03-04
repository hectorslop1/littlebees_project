import { LogType } from './enums';

export interface DailyLogEntryResponse {
  id: string;
  childId: string;
  childName: string;
  date: string;
  type: LogType;
  title: string;
  description: string | null;
  time: string;
  metadata: LogMetadata;
  recordedBy: string;
  recordedByName: string;
  createdAt: string;
}

export interface CreateDailyLogRequest {
  childId: string;
  date: string;
  type: LogType;
  title: string;
  description?: string;
  time: string;
  metadata?: LogMetadata;
}

export interface BulkCreateDailyLogRequest {
  childIds: string[];
  date: string;
  type: LogType;
  title: string;
  description?: string;
  time: string;
  metadata?: LogMetadata;
}

// Metadata varies by log type
export type LogMetadata = MealMetadata | NapMetadata | DiaperMetadata | ActivityMetadata | Record<string, unknown>;

export interface MealMetadata {
  food: string;
  quantity: 'none' | 'little' | 'half' | 'most' | 'all';
  mealType: 'breakfast' | 'lunch' | 'snack' | 'dinner';
}

export interface NapMetadata {
  durationMinutes: number;
  quality: 'good' | 'fair' | 'poor';
}

export interface DiaperMetadata {
  type: 'wet' | 'dirty' | 'both' | 'dry';
}

export interface ActivityMetadata {
  imageUrls: string[];
  videoUrl?: string;
}
