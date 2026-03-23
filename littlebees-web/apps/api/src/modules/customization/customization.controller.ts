import { Body, Controller, Get, Patch, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@kinderspace/shared-types';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { CustomizationService } from './customization.service';
import { UpdateCustomizationDto } from './dto/update-customization.dto';

@ApiTags('customization')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('customization')
export class CustomizationController {
  constructor(private readonly customizationService: CustomizationService) {}

  @Get()
  @ApiOperation({ summary: 'Obtener la personalización del tenant actual' })
  getCustomization(@CurrentTenant() tenantId: string) {
    return this.customizationService.getCustomization(tenantId);
  }

  @Patch()
  @Roles(UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Actualizar la personalización del tenant actual' })
  updateCustomization(
    @CurrentTenant() tenantId: string,
    @Body() dto: UpdateCustomizationDto,
  ) {
    return this.customizationService.updateCustomization(tenantId, dto);
  }

  @Post('reset')
  @Roles(UserRole.DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Restablecer la personalización del tenant actual' })
  resetCustomization(@CurrentTenant() tenantId: string) {
    return this.customizationService.resetCustomization(tenantId);
  }
}
