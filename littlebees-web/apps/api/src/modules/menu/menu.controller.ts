import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { MenuService } from './menu.service';
import { MenuConfigDto } from './dto/menu-config.dto';

@ApiTags('menu')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('menu')
export class MenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get()
  @ApiOperation({ summary: 'Obtener configuración de menú según rol del usuario' })
  @ApiResponse({ status: 200, description: 'Configuración de menú', type: MenuConfigDto })
  async getMenu(@CurrentUser() user: any, @CurrentTenant() tenantId: string): Promise<MenuConfigDto> {
    const menuItems = await this.menuService.getMenuByRole(user.role, tenantId);
    return { items: menuItems };
  }
}
