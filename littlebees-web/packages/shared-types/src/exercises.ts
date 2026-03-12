import type { DevelopmentCategory } from './enums';

export interface Exercise {
  id: string;
  tenantId: string;
  title: string;
  description: string;
  category: DevelopmentCategory;
  duration: number; // minutes
  ageRangeMin: number; // months
  ageRangeMax: number; // months
  videoUrl?: string;
  createdAt: string;
  updatedAt: string;
}

export interface ChildExercise {
  childId: string;
  exerciseId: string;
  completed: boolean;
  completedAt?: string;
  exercise?: Exercise; // Populated from join
}

export interface CreateExerciseDto {
  title: string;
  description: string;
  category: DevelopmentCategory;
  duration: number;
  ageRangeMin: number;
  ageRangeMax: number;
  videoUrl?: string;
}

export interface UpdateExerciseDto {
  title?: string;
  description?: string;
  category?: DevelopmentCategory;
  duration?: number;
  ageRangeMin?: number;
  ageRangeMax?: number;
  videoUrl?: string;
}

export interface ExerciseListResponse {
  exercises: Exercise[];
  total: number;
}

export interface ChildExerciseListResponse {
  exercises: ChildExercise[];
  total: number;
}
