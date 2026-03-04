import { z } from 'zod';

export const createChildSchema = z.object({
  firstName: z.string().min(2, 'Mínimo 2 caracteres').max(100),
  lastName: z.string().min(2, 'Mínimo 2 caracteres').max(100),
  dateOfBirth: z.string().datetime({ message: 'Fecha inválida' }),
  gender: z.enum(['male', 'female']),
  groupId: z.string().uuid(),
  parentIds: z.array(z.string().uuid()).min(1, 'Al menos un padre/tutor requerido'),
});

export const updateChildSchema = z.object({
  firstName: z.string().min(2).max(100).optional(),
  lastName: z.string().min(2).max(100).optional(),
  groupId: z.string().uuid().optional(),
  status: z.enum(['active', 'inactive', 'graduated']).optional(),
});

export const updateMedicalInfoSchema = z.object({
  allergies: z.array(z.string()).optional(),
  conditions: z.array(z.string()).optional(),
  medications: z.array(z.string()).optional(),
  bloodType: z.string().max(5).optional(),
  observations: z.string().optional(),
  doctorName: z.string().max(200).optional(),
  doctorPhone: z.string().max(20).optional(),
});

export const createEmergencyContactSchema = z.object({
  name: z.string().min(2).max(200),
  relationship: z.string().min(2).max(50),
  phone: z.string().min(10).max(20),
  email: z.string().email().optional(),
});

export type CreateChildInput = z.infer<typeof createChildSchema>;
export type UpdateChildInput = z.infer<typeof updateChildSchema>;
export type UpdateMedicalInfoInput = z.infer<typeof updateMedicalInfoSchema>;
export type CreateEmergencyContactInput = z.infer<typeof createEmergencyContactSchema>;
