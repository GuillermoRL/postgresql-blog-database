import { Injectable } from '@nestjs/common'
import { DatabaseService } from './database.service'

@Injectable()
export class AnalyticsRepository {
  constructor(private db: DatabaseService) {}

  async getTopAuthors(period: string = '30d', category?: string, limit: number = 20) {
    const periodMap: Record<string, number> = {
      '30d': 30,
      '60d': 60,
      '90d': 90,
    }

    const days = periodMap[period] ?? 30

    const query = `
      WITH date_params AS (
        SELECT
          NOW() - INTERVAL '${days} days' AS period_start
      ),
      weighted_engagement AS (
        SELECT
          e.post_id,
          COUNT(*) FILTER (WHERE type = 'view') AS views,
          COUNT(*) FILTER (WHERE type = 'like') AS likes,
          COUNT(*) FILTER (WHERE type = 'comment') AS comments,
          COUNT(*) FILTER (WHERE type = 'share') AS shares,
          COUNT(*) FILTER (WHERE type = 'view') * 1 +
          COUNT(*) FILTER (WHERE type = 'like') * 3 +
          COUNT(*) FILTER (WHERE type = 'comment') * 5 +
          COUNT(*) FILTER (WHERE type = 'share') * 10 AS engagement_score
        FROM engagements e
        CROSS JOIN date_params
        WHERE e.engaged_timestamp >= date_params.period_start
        GROUP BY e.post_id
      ),
      author_metrics AS (
        SELECT
          a.author_id,
          a.name,
          a.author_category,
          COUNT(DISTINCT p.post_id) AS posts_count,
          COALESCE(SUM(we.engagement_score), 0) AS total_engagement,
          COALESCE(AVG(we.engagement_score), 0) AS avg_engagement_per_post,
          COALESCE(SUM(we.views), 0) AS total_views,
          COALESCE(SUM(we.shares), 0) AS total_shares
        FROM authors a
        JOIN posts p ON a.author_id = p.author_id
        LEFT JOIN weighted_engagement we ON p.post_id = we.post_id
        CROSS JOIN date_params
        WHERE p.publish_timestamp >= date_params.period_start
          ${category ? `AND a.author_category = $1` : ''}
        GROUP BY a.author_id, a.name, a.author_category
      )
      SELECT
        author_id,
        name,
        author_category,
        posts_count,
        total_engagement,
        ROUND(avg_engagement_per_post::numeric, 2) AS avg_engagement_per_post,
        total_views,
        total_shares,
        RANK() OVER (ORDER BY total_engagement DESC) AS engagement_rank
      FROM author_metrics
      ORDER BY total_engagement DESC
      LIMIT $${category ? '2' : '1'}
    `
    const params = category ? [category, limit] : [limit]
    const result = await this.db.query(query, params)
    return result.rows
  }

  async getTimePatterns(period: string = '90d', category?: string) {
    const periodMap: Record<string, number> = {
      '30d': 30,
      '60d': 60,
      '90d': 90,
    }
    const days = periodMap[period] || 90

    const query = `
        WITH engagement_times AS (
            SELECT
            e.type,
            EXTRACT(DOW FROM e.engaged_timestamp) AS day_of_week,
            EXTRACT(HOUR FROM e.engaged_timestamp) AS hour_of_day,
            p.category
            FROM engagements e
            JOIN posts p ON e.post_id = p.post_id
            WHERE e.engaged_timestamp >= NOW() - INTERVAL '${days} days'
            ${category ? `AND p.category = $1` : ''}
        )
        SELECT
            day_of_week,
            CASE day_of_week
            WHEN 0 THEN 'Sunday'
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
            END AS day_name,
            hour_of_day,
            ${category ? 'category,' : ''}
            COUNT(*) AS engagement_count,
            COUNT(*) FILTER (WHERE type = 'share') AS shares,
            ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (${category ? 'PARTITION BY category' : ''}), 2) AS pct_of_total
        FROM engagement_times
        GROUP BY day_of_week, hour_of_day ${category ? ', category' : ''}
        ORDER BY ${category ? 'category, ' : ''} day_of_week, hour_of_day
        `

    const params = category ? [category] : []
    const result = await this.db.query(query, params)

    return result.rows
  }

  async getOpportunityAnalysis(minPosts: number = 5, category?: string) {
    const query = `
        WITH author_performance AS (
            SELECT
            a.author_id,
            a.name,
            a.author_category,
            COUNT(DISTINCT p.post_id) AS post_count,
            COUNT(e.engagement_id) AS total_engagements,
            COALESCE(COUNT(e.engagement_id)::NUMERIC / NULLIF(COUNT(DISTINCT p.post_id), 0), 0) AS engagement_per_post,
            PERCENT_RANK() OVER (
                PARTITION BY a.author_category
                ORDER BY COUNT(DISTINCT p.post_id)
            ) AS volume_percentile,
            PERCENT_RANK() OVER (
                PARTITION BY a.author_category
                ORDER BY COUNT(e.engagement_id)::NUMERIC / NULLIF(COUNT(DISTINCT p.post_id), 0)
            ) AS engagement_percentile
            FROM authors a
            JOIN posts p ON a.author_id = p.author_id
            LEFT JOIN engagements e ON p.post_id = e.post_id
            WHERE p.publish_timestamp >= NOW() - INTERVAL '90 days'
            ${category ? `AND a.author_category = $2` : ''}
            GROUP BY a.author_id, a.name, a.author_category
            HAVING COUNT(DISTINCT p.post_id) >= $1
        )
        SELECT
            author_id,
            name,
            author_category,
            post_count,
            total_engagements,
            ROUND(engagement_per_post, 2) AS avg_engagement_per_post,
            ROUND(volume_percentile::NUMERIC * 100, 1) AS volume_pct,
            ROUND(engagement_percentile::NUMERIC * 100, 1) AS engagement_pct,
            CASE
            WHEN volume_percentile > 0.7 AND engagement_percentile < 0.3 THEN 'HIGH OPPORTUNITY'
            WHEN volume_percentile > 0.5 AND engagement_percentile < 0.5 THEN 'MEDIUM OPPORTUNITY'
            ELSE 'ON TRACK'
            END AS opportunity_segment
        FROM author_performance
        WHERE volume_percentile > 0.5
        ORDER BY
            CASE
            WHEN volume_percentile > 0.7 AND engagement_percentile < 0.3 THEN 1
            WHEN volume_percentile > 0.5 AND engagement_percentile < 0.5 THEN 2
            ELSE 3
            END,
            engagement_percentile ASC
        `

    const params = category ? [minPosts, category] : [minPosts]
    const result = await this.db.query(query, params)

    return result.rows
  }

  async getTrendComparison(postId: number, days: number = 7) {
    const query = `
        WITH current_period AS (
            SELECT
            COUNT(*) FILTER (WHERE type = 'view') AS views,
            COUNT(*) FILTER (WHERE type = 'like') AS likes,
            COUNT(*) FILTER (WHERE type = 'comment') AS comments,
            COUNT(*) FILTER (WHERE type = 'share') AS shares
            FROM engagements
            WHERE post_id = $1
            AND engaged_timestamp >= NOW() - INTERVAL '${days} days'
        ),
        previous_period AS (
            SELECT
            COUNT(*) FILTER (WHERE type = 'view') AS views,
            COUNT(*) FILTER (WHERE type = 'like') AS likes,
            COUNT(*) FILTER (WHERE type = 'comment') AS comments,
            COUNT(*) FILTER (WHERE type = 'share') AS shares
            FROM engagements
            WHERE post_id = $1
            AND engaged_timestamp >= NOW() - INTERVAL '${days * 2} days'
            AND engaged_timestamp < NOW() - INTERVAL '${days} days'
        )
        SELECT
            'current' AS period,
            current_period.*,
            CASE
            WHEN previous_period.views > 0
            THEN ROUND(((current_period.views - previous_period.views)::numeric / previous_period.views * 100), 2)
            ELSE NULL
            END AS views_change_pct,
            CASE
            WHEN previous_period.likes > 0
            THEN ROUND(((current_period.likes - previous_period.likes)::numeric / previous_period.likes * 100), 2)
            ELSE NULL
            END AS likes_change_pct
        FROM current_period, previous_period
        UNION ALL
        SELECT
            'previous' AS period,
            previous_period.*,
            NULL AS views_change_pct,
            NULL AS likes_change_pct
        FROM previous_period
        `

    const result = await this.db.query(query, [postId])
    return result.rows
  }
}
