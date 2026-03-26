import { ApiProperty } from '@nestjs/swagger';
import {
  ArrayMaxSize,
  IsArray,
  IsDateString,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';

export class CreateExcuseDto {
  @ApiProperty({ description: 'ID del niño' })
  @IsUUID()
  childId: string;

  @ApiProperty({ description: 'Tipo de justificante', example: 'medical' })
  @IsString()
  @MaxLength(50)
  type: string;

  @ApiProperty({ description: 'Título visible del justificante' })
  @IsString()
  @MaxLength(255)
  title: string;

  @ApiProperty({
    description: 'Descripción opcional para más contexto',
    required: false,
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Fecha del justificante en formato YYYY-MM-DD' })
  @IsDateString()
  date: string;

  @ApiProperty({
    description: 'Adjuntos opcionales (ids de archivo o URLs)',
    required: false,
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsString({ each: true })
  attachments?: string[];
}
