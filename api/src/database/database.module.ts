import { Module, Global } from '@nestjs/common'
import { DatabaseService } from '@database/database.service'
import { AnalyticsRepository } from './analytics.repository'

@Global()
@Module({
  providers: [DatabaseService, AnalyticsRepository],
  exports: [DatabaseService, AnalyticsRepository],
})
export class DatabaseModule {}
