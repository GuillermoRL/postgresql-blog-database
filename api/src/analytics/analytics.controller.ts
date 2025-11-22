import { Controller, Get, Query, Param, ParseIntPipe } from '@nestjs/common'
import { AnalyticsService } from './analytics.service'
import {
  TopAuthorsQueryDto,
  TimePatternQueryDto,
  OpportunityQueryDto,
  TrendQueryDto,
} from './dto/query-params.dto'

@Controller('analytics')
export class AnalyticsController {
  constructor(private analyticsService: AnalyticsService) {}

  @Get('top-authors')
  async getTopAuthors(@Query() query: TopAuthorsQueryDto) {
    const data = await this.analyticsService.getTopAuthors(
      query.period,
      query.category,
      query.limit,
    )

    return {
      success: true,
      data,
      meta: {
        period: query.period,
        category: query.category ?? 'all',
        count: data.length,
      },
    }
  }

  @Get('time-patterns')
  async getTimePatterns(@Query() query: TimePatternQueryDto) {
    const data = await this.analyticsService.getTimePatterns(query.period, query.category)

    return {
      success: true,
      data,
      meta: {
        period: query.period,
        category: query.category ?? 'all',
        count: data.length,
      },
    }
  }

  @Get('opportunities')
  async getOpportunities(@Query() query: OpportunityQueryDto) {
    const data = await this.analyticsService.getOpportunities(query.minPosts, query.category)

    return {
      success: true,
      data,
      meta: {
        minPosts: query.minPosts,
        category: query.category ?? 'all',
        count: data.length,
      },
    }
  }

  @Get('trends/:postId')
  async getTrends(@Param('postId', ParseIntPipe) postId: number, @Query() query: TrendQueryDto) {
    const data = await this.analyticsService.getTrends(postId, query.days)

    return {
      success: true,
      data,
      meta: {
        postId,
        days: query.days,
      },
    }
  }
}
