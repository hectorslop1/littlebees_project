import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentTenant } from '../../common/decorators/current-tenant.decorator';
import { ExercisesService } from './exercises.service';
import { CreateExerciseDto, UpdateExerciseDto } from './dto';

@ApiTags('exercises')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('exercises')
export class ExercisesController {
  constructor(private readonly exercisesService: ExercisesService) {}

  @Get()
  @ApiOperation({ summary: 'Listar ejercicios' })
  @ApiQuery({ name: 'category', required: false })
  @ApiQuery({ name: 'childId', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  findAll(
    @CurrentTenant() tenantId: string,
    @Query('category') category?: string,
    @Query('childId') childId?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.exercisesService.findAll(tenantId, {
      category,
      childId,
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 20,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener ejercicio por ID' })
  findOne(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.exercisesService.findOne(tenantId, id);
  }

  @Post()
  @ApiOperation({ summary: 'Crear ejercicio' })
  create(
    @CurrentTenant() tenantId: string,
    @Body() createExerciseDto: CreateExerciseDto,
  ) {
    return this.exercisesService.create(tenantId, createExerciseDto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar ejercicio' })
  update(
    @CurrentTenant() tenantId: string,
    @Param('id') id: string,
    @Body() updateExerciseDto: UpdateExerciseDto,
  ) {
    return this.exercisesService.update(tenantId, id, updateExerciseDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar ejercicio' })
  delete(@CurrentTenant() tenantId: string, @Param('id') id: string) {
    return this.exercisesService.delete(tenantId, id);
  }

  @Post(':exerciseId/children/:childId/toggle')
  @ApiOperation({ summary: 'Marcar/desmarcar ejercicio como completado' })
  toggleCompleted(
    @CurrentTenant() tenantId: string,
    @Param('exerciseId') exerciseId: string,
    @Param('childId') childId: string,
  ) {
    return this.exercisesService.toggleCompleted(tenantId, exerciseId, childId);
  }
}
