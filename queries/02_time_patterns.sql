WITH engagement_times AS (
    SELECT
        e.engagement_id,
        e.type,
        e.engaged_timestamp,
        EXTRACT(DOW FROM e.engaged_timestamp) AS day_of_week, -- 0=Sunday
        EXTRACT(HOUR FROM e.engaged_timestamp) AS hour_of_day,
        p.category
    FROM engagements e
    JOIN posts p ON e.post_id = p.post_id
    WHERE e.engaged_timestamp >= NOW() - INTERVAL '90 days'
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
    category,
    COUNT(*) AS engagement_count,
    COUNT(*) FILTER (WHERE type = 'share') AS shares,
    -- Engagement rate relative to total for that hour
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY category), 2) AS pct_of_category
FROM engagement_times
GROUP BY day_of_week, hour_of_day, category
ORDER BY category, day_of_week, hour_of_day;

-- ANALYSIS QUERY: Find best publishing windows
WITH hourly_engagement AS (
    SELECT
        EXTRACT(DOW FROM e.engaged_timestamp) AS day_of_week,
        EXTRACT(HOUR FROM e.engaged_timestamp) AS hour,
        COUNT(*) AS engagement_count
    FROM engagements e
    WHERE e.engaged_timestamp >= NOW() - INTERVAL '90 days'
    GROUP BY 1, 2
)
SELECT
    day_of_week,
    hour,
    engagement_count,
    RANK() OVER (ORDER BY engagement_count DESC) AS rank
FROM hourly_engagement
ORDER BY engagement_count DESC
LIMIT 10;

-- ASSUMPTION: All timestamps in UTC. In production, consider user timezone distribution