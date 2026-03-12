export interface Announcement {
  id: string;
  tenantId: string;
  title: string;
  content: string;
  type: 'general' | 'event' | 'alert' | 'achievement';
  priority: 'high' | 'medium' | 'low';
  authorId: string;
  authorName?: string; // Populated from join
  createdAt: string;
  updatedAt: string;
}

export interface CreateAnnouncementDto {
  title: string;
  content: string;
  type: 'general' | 'event' | 'alert' | 'achievement';
  priority: 'high' | 'medium' | 'low';
}

export interface UpdateAnnouncementDto {
  title?: string;
  content?: string;
  type?: 'general' | 'event' | 'alert' | 'achievement';
  priority?: 'high' | 'medium' | 'low';
}

export interface AnnouncementListResponse {
  announcements: Announcement[];
  total: number;
}
