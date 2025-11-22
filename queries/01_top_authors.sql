WITH date_params AS (
    SELECT
        NOW() - INTERVAL '30 days' AS period_start,
        NOW() - INTERVAL '60 days' AS comparison_start
),
weighted_engagement AS (
    SELECT
        e.post_id,
        -- Weight engagements by value (adjust based on business priorities)
        COUNT(*) FILTER (WHERE type = 'view') AS views,
        COUNT(*) FILTER (WHERE type = 'like') AS likes,
        COUNT(*) FILTER (WHERE type = 'comment') AS comments,
        COUNT(*) FILTER (WHERE type = 'share') AS shares,
        -- Weighted score: shares worth 10x views
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
    GROUP BY a.author_id, a.name, a.author_category
)
SELECT
    author_id,
    name,
    author_category,
    posts_count,
    total_engagement,
    avg_engagement_per_post,
    total_views,
    total_shares,
    RANK() OVER (ORDER BY total_engagement DESC) AS engagement_rank
FROM author_metrics
ORDER BY total_engagement DESC
LIMIT 20;

-- NOTES:
-- 1. FILTER clause more efficient than CASE SUM
-- 2. Covering indexes avoid table lookups
-- 3. For 100M+ rows, consider materialized view refreshed hourly
