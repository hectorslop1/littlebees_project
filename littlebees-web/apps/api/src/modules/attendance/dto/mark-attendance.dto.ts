import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class MarkAttendanceDto {
  @ApiProperty({
    description: 'ID del niño para registrar asistencia',
  })
  @IsUUID('4')
  childId: string;

  @ApiProperty({
    description: 'Estado a registrar',
    enum: ['present', 'absent'],
  })
  @IsIn(['present', 'absent'])
  status: 'present' | 'absent';

  @ApiProperty({
    description: 'Metodo del registro',
    required: false,
    example: 'teacher_manual',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  method?: string;

  @ApiProperty({
    description: 'Observaciones opcionales',
    required: false,
    example: 'No llego a clase',
  })
  @IsOptional()
  @IsString()
  observations?: string;

  @ApiProperty({
    description: 'Fecha lógica YYYY-MM-DD opcional enviada por el cliente',
    required: false,
    example: '2026-03-27',
  })
  @IsOptional()
  @IsString()
  date?: string;
}
