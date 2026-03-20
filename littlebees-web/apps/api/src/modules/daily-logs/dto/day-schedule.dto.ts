import { ApiProperty } from '@nestjs/swagger';

export class ScheduleItemDto {
  @ApiProperty()
  time: string;

  @ApiProperty()
  type: string;

  @ApiProperty()
  label: string;
}

export class ChildDayStatusDto {
  @ApiProperty()
  childId: string;

  @ApiProperty()
  firstName: string;

  @ApiProperty()
  lastName: string;

  @ApiProperty({ required: false })
  photoUrl?: string;

  @ApiProperty()
  hasCheckIn: boolean;

  @ApiProperty()
  hasMeal: boolean;

  @ApiProperty()
  hasNap: boolean;

  @ApiProperty()
  hasActivity: boolean;

  @ApiProperty()
  hasCheckOut: boolean;

  @ApiProperty({ required: false })
  checkInTime?: string;

  @ApiProperty({ required: false })
  checkOutTime?: string;

  @ApiProperty({ required: false })
  lastActivity?: string;
}

export class DayScheduleResponseDto {
  @ApiProperty()
  groupId: string;

  @ApiProperty()
  groupName: string;

  @ApiProperty()
  date: string;

  @ApiProperty({ type: [ScheduleItemDto] })
  schedule: ScheduleItemDto[];

  @ApiProperty({ type: [ChildDayStatusDto] })
  children: ChildDayStatusDto[];

  @ApiProperty()
  totalChildren: number;

  @ApiProperty()
  presentChildren: number;

  @ApiProperty()
  absentChildren: number;
}
