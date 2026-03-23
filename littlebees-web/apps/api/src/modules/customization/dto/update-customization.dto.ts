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

  @ApiPropertyOptional({ example: '#1A1410' })
  @IsOptional()
  @IsHexColor()
  sidebarBg?: string;

  @ApiPropertyOptional({ example: '#D1D5DB' })
  @IsOptional()
  @IsHexColor()
  sidebarText?: string;

  @ApiPropertyOptional({ example: '#FFFFFF' })
  @IsOptional()
  @IsHexColor()
  sidebarActiveText?: string;

  @ApiPropertyOptional({ example: '#FFFFFF' })
  @IsOptional()
  @IsHexColor()
  bgSurface?: string;

  @ApiPropertyOptional({ example: '#FBF6E9' })
  @IsOptional()
  @IsHexColor()
  bgPage?: string;

  @ApiPropertyOptional({ example: '#2C2C2C' })
  @IsOptional()
  @IsHexColor()
  textPrimary?: string;

  @ApiPropertyOptional({ example: '#6B6B6B' })
  @IsOptional()
  @IsHexColor()
  textSecondary?: string;

  @ApiPropertyOptional({ example: '#E5E7EB' })
  @IsOptional()
  @IsHexColor()
  borderColor?: string;

  @ApiPropertyOptional({ example: '#F3F4F6' })
  @IsOptional()
  @IsHexColor()
  tableHeaderBg?: string;

  @ApiPropertyOptional({ example: '#F9FAFB' })
  @IsOptional()
  @IsHexColor()
  tableStripeBg?: string;

  @ApiPropertyOptional({ example: '#FBF6E9' })
  @IsOptional()
  @IsHexColor()
  tableHoverBg?: string;

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
