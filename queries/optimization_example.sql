-- BEFORE: Slow query (no index utilization)
EXPLAIN ANALYZE
SELECT a.name, COUNT(e.engagement_id)
FROM authors a
JOIN posts p ON a.author_id = p.author_id
JOIN engagements e ON p.post_id = e.post_id
WHERE e.engaged_timestamp >= '2025-07-01'
GROUP BY a.author_id, a.name;

-- AFTER: With indexes
EXPLAIN ANALYZE
SELECT a.name, COUNT(e.engagement_id)
FROM authors a
JOIN posts p ON a.author_id = p.author_id
JOIN engagements e ON p.post_id = e.post_id
WHERE e.engaged_timestamp >= '2025-07-01'
GROUP BY a.author_id, a.name;

-- NOTES:
/*
At 100M+ engagements:
1. Partition engagements by month: 
    - faster queries on recent data
    - Easier archival of old data
    
2. Materialized views for common aggregations:
    - author_daily_stats (refresh every 6 hours)
    - category_hourly_engagement (refresh every hour)
    
3. Read replica for analytics:
    - Separate from transactional load
    - Can use column-store extension for analytical queries
*/
