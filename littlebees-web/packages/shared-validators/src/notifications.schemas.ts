import { z } from 'zod';

export const createNotificationSchema = z.object({
  userId: z.string().uuid(),
  type: z.string().min(1).max(50),
  title: z.string().min(1).max(255),
  body: z.string().min(1),
  data: z.record(z.unknown()).optional(),
  channel: z.enum(['push', 'email', 'sms', 'in_app']).default('in_app'),
});

export type CreateNotificationInput = z.infer<
  typeof createNotificationSchema
>;
