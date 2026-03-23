import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { FilesModule } from '../files/files.module';
import { CustomizationController } from './customization.controller';
import { CustomizationService } from './customization.service';

@Module({
  imports: [PrismaModule, FilesModule],
  controllers: [CustomizationController],
  providers: [CustomizationService],
  exports: [CustomizationService],
})
export class CustomizationModule {}
