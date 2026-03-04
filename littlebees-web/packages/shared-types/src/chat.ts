import { MessageType } from './enums';

export interface ConversationResponse {
  id: string;
  childId: string;
  childName: string;
  participants: ConversationParticipant[];
  lastMessage: MessageResponse | null;
  unreadCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface ConversationParticipant {
  userId: string;
  name: string;
  avatarUrl: string | null;
  role: string;
  lastReadAt: string | null;
}

export interface MessageResponse {
  id: string;
  conversationId: string;
  senderId: string;
  senderName: string;
  senderAvatarUrl: string | null;
  content: string;
  messageType: MessageType;
  attachmentUrl: string | null;
  createdAt: string;
}

export interface SendMessageRequest {
  content: string;
  messageType?: MessageType;
  attachmentUrl?: string;
}

export interface CreateConversationRequest {
  childId: string;
  participantIds: string[];
}
