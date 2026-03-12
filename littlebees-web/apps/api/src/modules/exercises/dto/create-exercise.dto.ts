import { IsString, IsEnum, IsInt, Min, IsOptional, IsUrl } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateExerciseDto {
  @ApiProperty({ example: 'Títeres de Dedo' })
  @IsString()
  title!: string;

  @ApiProperty({
    example: 'Usa títeres de dedo para contar historias y desarrollar el lenguaje',
  })
  @IsString()
  description!: string;

  @ApiProperty({
    enum: ['motor_fine', 'motor_gross', 'cognitive', 'language', 'social', 'emotional'],
  })
  @IsEnum(['motor_fine', 'motor_gross', 'cognitive', 'language', 'social', 'emotional'])
  category!: 'motor_fine' | 'motor_gross' | 'cognitive' | 'language' | 'social' | 'emotional';

  @ApiProperty({ example: 15, description: 'Duración en minutos' })
  @IsInt()
  @Min(1)
  duration!: number;

  @ApiProperty({ example: 12, description: 'Edad mínima en meses' })
  @IsInt()
  @Min(0)
  ageRangeMin!: number;

  @ApiProperty({ example: 48, description: 'Edad máxima en meses' })
  @IsInt()
  @Min(0)
  ageRangeMax!: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsUrl()
  videoUrl?: string;
}
