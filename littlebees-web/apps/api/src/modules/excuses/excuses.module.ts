import { Module } from '@nestjs/common';
import { ExcusesController } from './excuses.controller';
import { ExcusesService } from './excuses.service';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [NotificationsModule],
  controllers: [ExcusesController],
  providers: [ExcusesService],
  exports: [ExcusesService],
})
export class ExcusesModule {}
