import { ApiProperty } from '@nestjs/swagger';
import {
  ArrayMaxSize,
  IsArray,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

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

export class CreateVoiceCallDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  sdp: string;

  @ApiProperty({ required: false, example: 'calida' })
  @IsString()
  @IsOptional()
  voicePresetId?: string;
}

export class VoiceCallResponseDto {
  @ApiProperty()
  sdp: string;

  @ApiProperty()
  voicePresetId: string;

  @ApiProperty()
  voice: string;
}

export class VoiceTranscriptTurnDto {
  @ApiProperty({ required: false })
  @IsString()
  @IsOptional()
  itemId?: string;

  @ApiProperty({ enum: ['user', 'assistant'] })
  @IsString()
  @IsIn(['user', 'assistant'])
  role: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  content: string;
}

export class FinalizeVoiceSessionDto {
  @ApiProperty({ type: [VoiceTranscriptTurnDto] })
  @IsArray()
  @ArrayMaxSize(48)
  @ValidateNested({ each: true })
  @Type(() => VoiceTranscriptTurnDto)
  turns: VoiceTranscriptTurnDto[];

  @ApiProperty({ required: false, example: 'calida' })
  @IsString()
  @IsOptional()
  voicePresetId?: string;

  @ApiProperty({ required: false, example: 64000 })
  @IsInt()
  @Min(0)
  @Max(180000)
  @IsOptional()
  durationMs?: number;
}
