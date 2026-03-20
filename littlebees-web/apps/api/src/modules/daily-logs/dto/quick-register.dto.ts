import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsUUID, IsEnum, IsOptional, IsObject } from 'class-validator';

export enum QuickRegisterType {
  CHECK_IN = 'check_in',
  MEAL = 'meal',
  NAP = 'nap',
  ACTIVITY = 'activity',
  CHECK_OUT = 'check_out',
}

export class QuickRegisterDto {
  @ApiProperty({ description: 'ID del niño' })
  @IsUUID()
  childId: string;

  @ApiProperty({ 
    description: 'Tipo de registro',
    enum: QuickRegisterType,
  })
  @IsEnum(QuickRegisterType)
  type: QuickRegisterType;

  @ApiProperty({ 
    description: 'Metadatos adicionales (incluye photoUrl para check_in/check_out)',
    required: false,
  })
  @IsOptional()
  @IsObject()
  metadata?: {
    photoUrl?: string;
    notes?: string;
    mood?: string;
    foodEaten?: string;
    napDuration?: number;
    activityDescription?: string;
    [key: string]: any;
  };
}

export class QuickRegisterResponseDto {
  @ApiProperty()
  dailyLogEntry: any;

  @ApiProperty({ required: false })
  attendanceRecord?: any;

  @ApiProperty()
  message: string;
}
