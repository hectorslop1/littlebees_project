import { z } from 'zod';

export const uploadFileSchema = z.object({
  purpose: z.enum(['avatar', 'evidence', 'document', 'attachment']),
});

export type UploadFileInput = z.infer<typeof uploadFileSchema>;
