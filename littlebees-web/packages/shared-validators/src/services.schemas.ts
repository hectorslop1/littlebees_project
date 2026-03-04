import { z } from 'zod';

export const createExtraServiceSchema = z.object({
  name: z.string().min(2).max(255),
  description: z.string().optional(),
  type: z.enum(['class', 'workshop', 'marketplace_item']),
  schedule: z.string().optional(),
  price: z.number().positive(),
  capacity: z.number().int().positive().optional(),
  imageUrl: z.string().url().optional(),
});

export const updateExtraServiceSchema = createExtraServiceSchema
  .partial()
  .extend({
    status: z.enum(['active', 'inactive']).optional(),
  });

export type CreateExtraServiceInput = z.infer<
  typeof createExtraServiceSchema
>;
export type UpdateExtraServiceInput = z.infer<
  typeof updateExtraServiceSchema
>;
