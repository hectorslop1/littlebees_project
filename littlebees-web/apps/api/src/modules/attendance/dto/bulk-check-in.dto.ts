import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsUUID, IsOptional, IsString } from 'class-validator';

export class BulkCheckInDto {
  @ApiProperty({ 
    description: 'Array de IDs de niños para check-in masivo',
    type: [String],
  })
  @IsArray()
  @IsUUID('4', { each: true })
  childIds: string[];

  @ApiProperty({ 
    description: 'URL de foto grupal (opcional)',
    required: false,
  })
  @IsOptional()
  @IsString()
  photoUrl?: string;

  @ApiProperty({ 
    description: 'Observaciones generales (opcional)',
    required: false,
  })
  @IsOptional()
  @IsString()
  observations?: string;
}

export class BulkCheckInResponseDto {
  @ApiProperty()
  successCount: number;

  @ApiProperty()
  failedCount: number;

  @ApiProperty({ type: [String] })
  successIds: string[];

  @ApiProperty({ type: [String] })
  failedIds: string[];

  @ApiProperty()
  message: string;
}
