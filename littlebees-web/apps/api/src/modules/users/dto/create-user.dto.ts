import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MinLength, IsEnum, IsOptional } from 'class-validator';
import { UserRole } from '@kinderspace/shared-types';

export class CreateUserDto {
  @ApiProperty({ example: 'juan.perez@example.com' })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ example: 'SecurePassword123!' })
  @IsString()
  @MinLength(8)
  @IsNotEmpty()
  password: string;

  @ApiProperty({ example: 'Juan' })
  @IsString()
  @IsNotEmpty()
  firstName: string;

  @ApiProperty({ example: 'Pérez' })
  @IsString()
  @IsNotEmpty()
  lastName: string;

  @ApiProperty({ example: '+52 55 1234 5678', required: false })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiProperty({ enum: UserRole, example: 'teacher' })
  @IsEnum(UserRole)
  @IsNotEmpty()
  role: UserRole;
}
