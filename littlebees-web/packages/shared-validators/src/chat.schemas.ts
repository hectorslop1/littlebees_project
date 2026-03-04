import { z } from 'zod';

export const createConversationSchema = z.object({
  childId: z.string().uuid(),
  participantIds: z.array(z.string().uuid()).min(1),
});

export const sendMessageSchema = z.object({
  content: z.string().min(1).max(5000),
  messageType: z.enum(['text', 'image', 'file', 'system']).default('text'),
  attachmentUrl: z.string().url().optional(),
});

export type CreateConversationInput = z.infer<
  typeof createConversationSchema
>;
export type SendMessageInput = z.infer<typeof sendMessageSchema>;
