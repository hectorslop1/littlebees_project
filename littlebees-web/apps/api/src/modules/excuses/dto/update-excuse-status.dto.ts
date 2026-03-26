import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateExcuseStatusDto {
  @ApiProperty({ description: 'Nuevo estado', example: 'approved' })
  @IsString()
  @MaxLength(20)
  status: string;

  @ApiProperty({
    description: 'Notas internas o explicación de la revisión',
    required: false,
  })
  @IsOptional()
  @IsString()
  reviewNotes?: string;
}
