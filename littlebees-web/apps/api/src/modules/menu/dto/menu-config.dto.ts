import { ApiProperty } from '@nestjs/swagger';

export class MenuItemDto {
  @ApiProperty({ example: 'dashboard' })
  id: string;

  @ApiProperty({ example: 'Dashboard' })
  label: string;

  @ApiProperty({ example: 'home' })
  icon: string;

  @ApiProperty({ example: '/dashboard' })
  path: string;

  @ApiProperty({ example: 1 })
  order: number;
}

export class MenuConfigDto {
  @ApiProperty({ type: [MenuItemDto] })
  items: MenuItemDto[];
}
