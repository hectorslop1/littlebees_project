import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateSessionDto {
  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  title?: string;
}

export class ChatMessageDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  message: string;
}

export class SessionResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;

  @ApiProperty({ required: false })
  messages?: MessageResponseDto[];
}

export class MessageResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ enum: ['user', 'assistant', 'system'] })
  role: string;

  @ApiProperty()
  content: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty({ required: false })
  metadata?: any;
}

export class ChatResponseDto {
  @ApiProperty()
  message: MessageResponseDto;

  @ApiProperty({ required: false })
  usage?: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}
