import { z } from 'zod';

export const createMilestoneSchema = z.object({
  category: z.enum([
    'motor_fine',
    'motor_gross',
    'cognitive',
    'language',
    'social',
    'emotional',
  ]),
  title: z.string().min(3).max(255),
  description: z.string().optional(),
  ageRangeMin: z.number().int().min(0).max(72),
  ageRangeMax: z.number().int().min(0).max(72),
  sortOrder: z.number().int().min(0),
});

export const updateMilestoneSchema = createMilestoneSchema.partial();

export const createDevelopmentRecordSchema = z.object({
  childId: z.string().uuid(),
  milestoneId: z.string().uuid(),
  status: z.enum(['achieved', 'in_progress', 'not_achieved']),
  observations: z.string().optional(),
  evidenceUrls: z.array(z.string().url()).optional(),
});

export const updateDevelopmentRecordSchema = z.object({
  status: z.enum(['achieved', 'in_progress', 'not_achieved']).optional(),
  observations: z.string().optional(),
  evidenceUrls: z.array(z.string().url()).optional(),
});

export type CreateMilestoneInput = z.infer<typeof createMilestoneSchema>;
export type UpdateMilestoneInput = z.infer<typeof updateMilestoneSchema>;
export type CreateDevelopmentRecordInput = z.infer<
  typeof createDevelopmentRecordSchema
>;
export type UpdateDevelopmentRecordInput = z.infer<
  typeof updateDevelopmentRecordSchema
>;
