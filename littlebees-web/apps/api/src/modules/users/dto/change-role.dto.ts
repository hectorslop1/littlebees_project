import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty } from 'class-validator';
import { UserRole } from '@kinderspace/shared-types';

export class ChangeRoleDto {
  @ApiProperty({ enum: UserRole, example: 'teacher' })
  @IsEnum(UserRole)
  @IsNotEmpty()
  role: UserRole;
}
