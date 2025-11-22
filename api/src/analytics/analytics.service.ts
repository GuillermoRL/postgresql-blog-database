import { Injectable } from '@nestjs/common'
import { AnalyticsRepository } from '../database/analytics.repository'

@Injectable()
export class AnalyticsService {
  constructor(private analyticsRepository: AnalyticsRepository) {}

  async getTopAuthors(period?: string, category?: string, limit?: number) {
    return this.analyticsRepository.getTopAuthors(period || '30d', category, limit || 20)
  }

  async getTimePatterns(period?: string, category?: string) {
    return this.analyticsRepository.getTimePatterns(period || '90d', category)
  }

  async getOpportunities(minPosts?: number, category?: string) {
    return this.analyticsRepository.getOpportunityAnalysis(minPosts || 5, category)
  }

  async getTrends(postId: number, days?: number) {
    return this.analyticsRepository.getTrendComparison(postId, days || 7)
  }
}
