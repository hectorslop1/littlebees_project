import { IsString, IsEnum, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateAnnouncementDto {
  @ApiProperty({ example: 'Feria del Día del Niño' })
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty({
    example:
      'Les informamos que el próximo 30 de abril celebraremos el Día del Niño con una feria especial.',
  })
  @IsString()
  @IsNotEmpty()
  content!: string;

  @ApiProperty({ enum: ['general', 'event', 'alert', 'achievement'] })
  @IsEnum(['general', 'event', 'alert', 'achievement'])
  type!: 'general' | 'event' | 'alert' | 'achievement';

  @ApiProperty({ enum: ['high', 'medium', 'low'] })
  @IsEnum(['high', 'medium', 'low'])
  priority!: 'high' | 'medium' | 'low';
}
