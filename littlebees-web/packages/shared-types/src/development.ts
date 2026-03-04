import { DevelopmentCategory, MilestoneStatus } from './enums';

export interface DevelopmentRecordResponse {
  id: string;
  childId: string;
  milestoneId: string;
  milestoneTitle: string;
  category: DevelopmentCategory;
  status: MilestoneStatus;
  observations: string | null;
  evaluatedAt: string;
  evaluatedBy: string;
  evaluatedByName: string;
  evidenceUrls: string[];
}

export interface CreateDevelopmentRecordRequest {
  childId: string;
  milestoneId: string;
  status: MilestoneStatus;
  observations?: string;
  evidenceUrls?: string[];
}

export interface MilestoneResponse {
  id: string;
  category: DevelopmentCategory;
  title: string;
  description: string;
  ageRangeMin: number; // months
  ageRangeMax: number; // months
  sortOrder: number;
}

export interface DevelopmentSummaryResponse {
  childId: string;
  childName: string;
  ageMonths: number;
  categories: CategorySummary[];
  recentAchievements: DevelopmentRecordResponse[];
}

export interface CategorySummary {
  category: DevelopmentCategory;
  totalMilestones: number;
  achieved: number;
  inProgress: number;
  notAchieved: number;
  progressPercent: number;
}
