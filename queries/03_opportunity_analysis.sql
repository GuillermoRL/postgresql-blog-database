WITH author_performance AS (
    SELECT
        a.author_id,
        a.name,
        a.author_category,
        COUNT(DISTINCT p.post_id) AS post_count,
        COUNT(e.engagement_id) AS total_engagements,
        COALESCE(COUNT(e.engagement_id)::NUMERIC / NULLIF(COUNT(DISTINCT p.post_id), 0), 0) AS engagement_per_post,
        -- Calculate percentile within category
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
    GROUP BY a.author_id, a.name, a.author_category
    HAVING COUNT(DISTINCT p.post_id) >= 5  -- Minimum volume threshold
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
    -- Opportunity score: high volume, low engagement
    CASE
        WHEN volume_percentile > 0.7 AND engagement_percentile < 0.3 THEN 'HIGH OPPORTUNITY'
        WHEN volume_percentile > 0.5 AND engagement_percentile < 0.5 THEN 'MEDIUM OPPORTUNITY'
        ELSE 'ON TRACK'
    END AS opportunity_segment
FROM author_performance
WHERE volume_percentile > 0.5  -- Focus on above-average publishers
ORDER BY
    CASE
        WHEN volume_percentile > 0.7 AND engagement_percentile < 0.3 THEN 1
        WHEN volume_percentile > 0.5 AND engagement_percentile < 0.5 THEN 2
        ELSE 3
    END,
    engagement_percentile ASC;

-- RECOMMENDATION: Authors in HIGH OPPORTUNITY need:
-- 1. Content quality review
-- 2. Title/headline optimization
-- 3. Publishing time adjustment