import { ApiProperty } from '@nestjs/swagger';

export class EmergencyContactDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  relationship: string;

  @ApiProperty()
  phone: string;

  @ApiProperty({ required: false })
  email?: string;

  @ApiProperty()
  priority: number;
}

export class ParentInfoDto {
  @ApiProperty()
  userId: string;

  @ApiProperty()
  firstName: string;

  @ApiProperty()
  lastName: string;

  @ApiProperty()
  email: string;

  @ApiProperty({ required: false })
  phone?: string;

  @ApiProperty()
  relationship: string;

  @ApiProperty()
  isPrimary: boolean;

  @ApiProperty()
  canPickup: boolean;
}

export class MedicalInfoDto {
  @ApiProperty({ type: [String] })
  allergies: string[];

  @ApiProperty({ type: [String] })
  conditions: string[];

  @ApiProperty({ type: [String] })
  medications: string[];

  @ApiProperty({ required: false })
  bloodType?: string;

  @ApiProperty({ required: false })
  observations?: string;

  @ApiProperty({ required: false })
  doctorName?: string;

  @ApiProperty({ required: false })
  doctorPhone?: string;

  @ApiProperty({ required: false })
  medicalNotes?: string;
}

export class ChildProfileDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  firstName: string;

  @ApiProperty()
  lastName: string;

  @ApiProperty()
  dateOfBirth: Date;

  @ApiProperty()
  gender: string;

  @ApiProperty({ required: false })
  photoUrl?: string;

  @ApiProperty()
  groupId: string;

  @ApiProperty()
  groupName: string;

  @ApiProperty()
  enrollmentDate: Date;

  @ApiProperty()
  status: string;

  @ApiProperty({ required: false })
  diagnosis?: string;

  @ApiProperty({ type: MedicalInfoDto, required: false })
  medicalInfo?: MedicalInfoDto;

  @ApiProperty({ type: [EmergencyContactDto] })
  emergencyContacts: EmergencyContactDto[];

  @ApiProperty({ type: [ParentInfoDto] })
  parents: ParentInfoDto[];

  @ApiProperty()
  age: number;
}
