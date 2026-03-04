import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Query,
  Body,
  UseGuards,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery, ApiConsumes } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { UserRole } from '@kinderspace/shared-types';
import { FilesService } from './files.service';

@ApiTags('files')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('files')
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  @Post('upload')
  @ApiOperation({ summary: 'Subir archivo directamente' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(
    FileInterceptor('file', { limits: { fileSize: 10 * 1024 * 1024 } }),
  )
  upload(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @UploadedFile() file: { originalname: string; mimetype: string; size: number; buffer: Buffer },
    @Body('purpose') purpose: string,
  ) {
    return this.filesService.upload(tenantId, userId, file, purpose);
  }

  @Post('presigned-upload')
  @ApiOperation({ summary: 'Obtener URL pre-firmada para subir desde cliente' })
  presignedUpload(
    @CurrentTenant() tenantId: string,
    @CurrentUser('id') userId: string,
    @Body() dto: { filename: string; mimeType: string; purpose: string },
  ) {
    return this.filesService.getPresignedUploadUrl(
      tenantId,
      userId,
      dto.filename,
      dto.mimeType,
      dto.purpose,
    );
  }

  @Get()
  @ApiOperation({ summary: 'Listar archivos' })
  @ApiQuery({ name: 'purpose', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  findAll(
    @CurrentTenant() tenantId: string,
    @Query('purpose') purpose?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.filesService.findAll(tenantId, {
      purpose,
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener archivo con URL de descarga' })
  findById(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.filesService.findById(tenantId, id);
  }

  @Delete(':id')
  @Roles(UserRole.SUPER_ADMIN, UserRole.DIRECTOR, UserRole.ADMIN)
  @ApiOperation({ summary: 'Eliminar archivo' })
  delete(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.filesService.delete(tenantId, id);
  }
}
