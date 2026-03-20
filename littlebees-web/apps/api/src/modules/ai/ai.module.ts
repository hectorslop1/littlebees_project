import { Module } from '@nestjs/common';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { PrismaModule } from '../prisma/prisma.module';
import { ContextBuilderService } from './services/context-builder.service';
import { AiFunctionsService } from './services/ai-functions.service';

@Module({
  imports: [PrismaModule],
  controllers: [AiController],
  providers: [AiService, ContextBuilderService, AiFunctionsService],
  exports: [AiService],
})
export class AiModule {}
