import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateExerciseDto, UpdateExerciseDto } from './dto';

@Injectable()
export class ExercisesService {
  constructor(private prisma: PrismaService) {}

  async findAll(
    tenantId: string,
    filters: {
      category?: string;
      childId?: string;
      page?: number;
      limit?: number;
    },
  ) {
    const { category, childId, page = 1, limit = 20 } = filters;
    const skip = (page - 1) * limit;

    const where: any = { tenantId };
    if (category) where.category = category;

    const [exercises, total] = await Promise.all([
      this.prisma.exercise.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
        include: childId
          ? {
              childExercises: {
                where: { childId },
                select: {
                  completed: true,
                  completedAt: true,
                },
              },
            }
          : undefined,
      }),
      this.prisma.exercise.count({ where }),
    ]);

    // Transform to include completion status if childId provided
    const transformedExercises = exercises.map((exercise) => {
      // TODO: Implementar relación childExercises en el schema de Prisma
      // if (childId && exercise.childExercises) {
      //   const childExercise = exercise.childExercises[0];
      //   return {
      //     ...exercise,
      //     completed: childExercise?.completed || false,
      //     completedAt: childExercise?.completedAt || null,
      //     childExercises: undefined,
      //   };
      // }
      return exercise;
    });

    return {
      exercises: transformedExercises,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(tenantId: string, id: string) {
    const exercise = await this.prisma.exercise.findFirst({
      where: { id, tenantId },
    });

    if (!exercise) {
      throw new NotFoundException('Ejercicio no encontrado');
    }

    return exercise;
  }

  async create(tenantId: string, createExerciseDto: CreateExerciseDto) {
    return this.prisma.exercise.create({
      data: {
        ...createExerciseDto,
        tenantId,
      },
    });
  }

  async update(
    tenantId: string,
    id: string,
    updateExerciseDto: UpdateExerciseDto,
  ) {
    await this.findOne(tenantId, id);

    return this.prisma.exercise.update({
      where: { id },
      data: updateExerciseDto,
    });
  }

  async delete(tenantId: string, id: string) {
    await this.findOne(tenantId, id);

    await this.prisma.exercise.delete({
      where: { id },
    });

    return { message: 'Ejercicio eliminado exitosamente' };
  }

  async toggleCompleted(tenantId: string, exerciseId: string, childId: string) {
    // Verify exercise exists and belongs to tenant
    await this.findOne(tenantId, exerciseId);

    // Verify child exists and belongs to tenant
    const child = await this.prisma.child.findFirst({
      where: { id: childId, tenantId },
    });

    if (!child) {
      throw new NotFoundException('Niño no encontrado');
    }

    // Check if relation exists
    const existing = await this.prisma.childExercise.findUnique({
      where: {
        childId_exerciseId: {
          childId,
          exerciseId,
        },
      },
    });

    if (existing) {
      // Toggle completion status
      return this.prisma.childExercise.update({
        where: {
          childId_exerciseId: {
            childId,
            exerciseId,
          },
        },
        data: {
          completed: !existing.completed,
          completedAt: !existing.completed ? new Date() : null,
        },
      });
    } else {
      // Create new relation as completed
      return this.prisma.childExercise.create({
        data: {
          childId,
          exerciseId,
          completed: true,
          completedAt: new Date(),
        },
      });
    }
  }
}
