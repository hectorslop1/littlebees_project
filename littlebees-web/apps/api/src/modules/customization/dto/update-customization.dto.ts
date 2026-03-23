import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsHexColor, IsObject, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateCustomizationDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  logoUrl?: string;

  @ApiPropertyOptional({ example: '#D4A853' })
  @IsOptional()
  @IsHexColor()
  primaryColor?: string;

  @ApiPropertyOptional({ example: '#8FAE8B' })
  @IsOptional()
  @IsHexColor()
  secondaryColor?: string;

  @ApiPropertyOptional({ example: '#E8B84B' })
  @IsOptional()
  @IsHexColor()
  accentColor?: string;

  @ApiPropertyOptional({ example: 'LittleBees Petit Soleil' })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  systemName?: string;

  @ApiPropertyOptional({ type: Object })
  @IsOptional()
  @IsObject()
  menuLabels?: Record<string, string>;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  customCss?: string;
}
