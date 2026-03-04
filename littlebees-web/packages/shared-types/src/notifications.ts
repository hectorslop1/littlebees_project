import { NotificationChannel } from './enums';

export interface NotificationResponse {
  id: string;
  userId: string;
  type: string;
  title: string;
  body: string;
  data: Record<string, unknown> | null;
  read: boolean;
  readAt: string | null;
  channel: NotificationChannel;
  createdAt: string;
}

export interface CreateNotificationRequest {
  userId: string;
  type: string;
  title: string;
  body: string;
  data?: Record<string, unknown>;
  channel?: NotificationChannel;
}

export interface NotificationCountResponse {
  total: number;
  unread: number;
}
