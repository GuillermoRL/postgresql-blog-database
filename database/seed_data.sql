-- ============================================================================
-- AUTHORS
-- ============================================================================

INSERT INTO authors (name, joined_date, author_category) VALUES
('Alice Chen', '2020-01-14', 'Tech'),
('Bob Martinez', '2019-06-30', 'Lifestyle'),
('Carlos Rodriguez', '2021-11-05', 'Tech'),
('Diana Kumar', '2021-03-22', 'Lifestyle'),
('Erik Hansen', '2020-09-15', 'Tech'),
('Fatima Ali', '2022-01-10', 'Lifestyle'),
('Grace Park', '2019-12-01', 'Tech');

-- ============================================================================
-- USERS
-- ============================================================================

INSERT INTO users (signup_date, country, user_segment) VALUES
('2025-01-10', 'US', 'free'),
('2025-02-12', 'UK', 'subscriber'),
('2024-12-05', 'US', 'trial'),
('2025-03-15', 'CA', 'premium'),
('2024-11-20', 'US', 'free'),
('2025-04-01', 'UK', 'subscriber'),
('2025-01-25', 'US', 'premium'),
('2024-10-10', 'AU', 'free'),
('2025-02-28', 'US', 'trial'),
('2025-03-05', 'CA', 'subscriber'),
('2024-09-15', 'UK', 'free'),
('2025-01-18', 'US', 'premium'),
('2025-04-12', 'DE', 'subscriber'),
('2024-12-01', 'US', 'free'),
('2025-02-14', 'UK', 'trial');

-- ============================================================================
-- POSTS - Mix of high and low performing content
-- ============================================================================

-- Alice's Tech posts (high engagement)
INSERT INTO posts (author_id, category, publish_timestamp, title, content_length, has_media) VALUES
(1, 'Tech', '2025-08-01 10:15:00', 'Deep Dive into PostgreSQL 17', 1200, true),
(1, 'Tech', '2025-08-05 09:30:00', 'Optimizing Database Queries', 1500, true),
(1, 'Tech', '2025-08-10 14:20:00', 'Building Scalable APIs', 1800, false),
(1, 'Tech', '2025-08-15 11:00:00', 'Microservices Best Practices', 2200, true),

-- Bob's Lifestyle posts (medium engagement)
(2, 'Lifestyle', '2025-08-02 17:30:00', '5 Morning Routines That Work', 800, false),
(2, 'Lifestyle', '2025-08-07 18:00:00', 'Meditation for Beginners', 950, true),
(2, 'Lifestyle', '2025-08-12 17:45:00', 'Healthy Eating on a Budget', 1100, true),

-- Carlos's Tech posts (high volume, low engagement - opportunity case)
(3, 'Tech', '2025-08-03 08:45:00', 'Why We Love SQL', 950, true),
(3, 'Tech', '2025-08-04 09:00:00', 'Introduction to TypeScript', 750, false),
(3, 'Tech', '2025-08-06 10:30:00', 'Getting Started with Node.js', 680, false),
(3, 'Tech', '2025-08-08 11:15:00', 'Understanding Async/Await', 820, false),
(3, 'Tech', '2025-08-11 09:45:00', 'JavaScript Tips and Tricks', 600, false),
(3, 'Tech', '2025-08-14 10:00:00', 'REST API Design', 720, false),

-- Diana's Lifestyle posts (good engagement)
(4, 'Lifestyle', '2025-08-09 16:30:00', 'Work-Life Balance Tips', 1300, true),
(4, 'Lifestyle', '2025-08-13 17:00:00', 'Productivity Hacks', 1150, true),

-- Erik's Tech posts (medium engagement)
(5, 'Tech', '2025-08-16 10:45:00', 'Docker for Developers', 1400, true),
(5, 'Tech', '2025-08-17 11:30:00', 'Kubernetes Basics', 1600, true),

-- Fatima's Lifestyle posts (lower engagement)
(6, 'Lifestyle', '2025-08-18 15:00:00', 'Minimalist Living', 900, false),
(6, 'Lifestyle', '2025-08-19 16:15:00', 'Home Organization Ideas', 850, false),

-- Grace's Tech posts (highest engagement)
(7, 'Tech', '2025-08-20 09:00:00', 'AI and Machine Learning Trends', 2500, true),
(7, 'Tech', '2025-08-21 10:30:00', 'The Future of Web Development', 2100, true);

-- ============================================================================
-- POST METADATA
-- ============================================================================

INSERT INTO post_metadata (post_id, tags, is_promoted, language) VALUES
(1, ARRAY['SQL', 'Optimization', 'PostgreSQL'], false, 'en'),
(2, ARRAY['SQL', 'Performance', 'Database'], false, 'en'),
(3, ARRAY['API', 'Architecture', 'Scalability'], true, 'en'),
(4, ARRAY['Microservices', 'Architecture', 'DevOps'], false, 'en'),
(5, ARRAY['Wellness', 'Morning', 'Productivity'], true, 'en'),
(6, ARRAY['Meditation', 'Wellness', 'Mental Health'], false, 'en'),
(7, ARRAY['Nutrition', 'Budget', 'Health'], false, 'en'),
(8, ARRAY['SQL', 'PostgreSQL', 'Tips'], false, 'en'),
(9, ARRAY['TypeScript', 'JavaScript', 'Programming'], false, 'en'),
(10, ARRAY['Node.js', 'Backend', 'JavaScript'], false, 'en'),
(11, ARRAY['JavaScript', 'Async', 'Programming'], false, 'en'),
(12, ARRAY['JavaScript', 'Tips', 'Frontend'], false, 'en'),
(13, ARRAY['API', 'REST', 'Design'], false, 'en'),
(14, ARRAY['Work', 'Balance', 'Wellness'], true, 'en'),
(15, ARRAY['Productivity', 'Tips', 'Work'], false, 'en'),
(16, ARRAY['Docker', 'DevOps', 'Containers'], false, 'en'),
(17, ARRAY['Kubernetes', 'DevOps', 'Containers'], true, 'en'),
(18, ARRAY['Minimalism', 'Lifestyle', 'Simplicity'], false, 'en'),
(19, ARRAY['Organization', 'Home', 'Tips'], false, 'en'),
(20, ARRAY['AI', 'ML', 'Trends', 'Future'], true, 'en'),
(21, ARRAY['Web', 'Development', 'Future', 'Trends'], false, 'en');

-- ============================================================================
-- ENGAGEMENTS - Realistic patterns across different times
-- ============================================================================

-- Post 1 (Alice - High engagement, good distribution)
INSERT INTO engagements (post_id, type, user_id, engaged_timestamp) VALUES
(1, 'view', 1, '2025-08-01 10:16:00'),
(1, 'view', 2, '2025-08-01 10:20:00'),
(1, 'view', 3, '2025-08-01 10:45:00'),
(1, 'view', 4, '2025-08-01 11:30:00'),
(1, 'view', 5, '2025-08-01 14:15:00'),
(1, 'like', 2, '2025-08-01 10:21:00'),
(1, 'like', 3, '2025-08-01 10:50:00'),
(1, 'like', 4, '2025-08-01 11:35:00'),
(1, 'comment', 2, '2025-08-01 10:25:00'),
(1, 'comment', 4, '2025-08-01 12:00:00'),
(1, 'share', 3, '2025-08-01 11:00:00'),
(1, 'share', 4, '2025-08-01 12:15:00'),

-- Post 2 (Alice - High engagement)
(2, 'view', 1, '2025-08-05 09:35:00'),
(2, 'view', 2, '2025-08-05 10:00:00'),
(2, 'view', 6, '2025-08-05 13:20:00'),
(2, 'view', 7, '2025-08-05 15:45:00'),
(2, 'like', 1, '2025-08-05 09:40:00'),
(2, 'like', 6, '2025-08-05 13:25:00'),
(2, 'comment', 7, '2025-08-05 15:50:00'),
(2, 'share', 6, '2025-08-05 14:00:00'),

-- Post 3 (Alice - Medium engagement)
(3, 'view', 8, '2025-08-10 14:25:00'),
(3, 'view', 9, '2025-08-10 15:00:00'),
(3, 'view', 10, '2025-08-10 16:30:00'),
(3, 'like', 8, '2025-08-10 14:30:00'),
(3, 'like', 10, '2025-08-10 16:35:00'),
(3, 'comment', 9, '2025-08-10 15:15:00'),

-- Post 4 (Alice - High engagement)
(4, 'view', 11, '2025-08-15 11:05:00'),
(4, 'view', 12, '2025-08-15 11:30:00'),
(4, 'view', 13, '2025-08-15 13:45:00'),
(4, 'view', 14, '2025-08-15 14:20:00'),
(4, 'like', 11, '2025-08-15 11:10:00'),
(4, 'like', 12, '2025-08-15 11:35:00'),
(4, 'like', 13, '2025-08-15 13:50:00'),
(4, 'comment', 12, '2025-08-15 11:40:00'),
(4, 'share', 13, '2025-08-15 14:00:00'),

-- Post 5 (Bob - Medium engagement, evening pattern)
(5, 'view', 1, '2025-08-02 17:45:00'),
(5, 'view', 2, '2025-08-02 18:00:00'),
(5, 'view', 3, '2025-08-02 19:30:00'),
(5, 'like', 2, '2025-08-02 18:05:00'),
(5, 'comment', 3, '2025-08-02 19:45:00'),

-- Post 6 (Bob - Good engagement)
(6, 'view', 4, '2025-08-07 18:10:00'),
(6, 'view', 5, '2025-08-07 18:45:00'),
(6, 'view', 6, '2025-08-07 19:00:00'),
(6, 'like', 4, '2025-08-07 18:15:00'),
(6, 'like', 5, '2025-08-07 18:50:00'),
(6, 'share', 6, '2025-08-07 19:15:00'),

-- Post 7 (Bob - Good engagement)
(7, 'view', 7, '2025-08-12 17:50:00'),
(7, 'view', 8, '2025-08-12 18:20:00'),
(7, 'view', 9, '2025-08-12 18:45:00'),
(7, 'like', 7, '2025-08-12 17:55:00'),
(7, 'like', 8, '2025-08-12 18:25:00'),
(7, 'comment', 9, '2025-08-12 18:50:00'),

-- Post 8 (Carlos - Low engagement despite good content)
(8, 'view', 10, '2025-08-03 09:00:00'),
(8, 'view', 11, '2025-08-03 10:30:00'),
(8, 'like', 10, '2025-08-03 09:05:00'),

-- Post 9 (Carlos - Low engagement)
(9, 'view', 12, '2025-08-04 09:15:00'),
(9, 'view', 13, '2025-08-04 11:00:00'),

-- Post 10 (Carlos - Low engagement)
(10, 'view', 14, '2025-08-06 10:45:00'),
(10, 'like', 14, '2025-08-06 10:50:00'),

-- Post 11 (Carlos - Low engagement)
(11, 'view', 15, '2025-08-08 11:30:00'),
(11, 'view', 1, '2025-08-08 12:00:00'),

-- Post 12 (Carlos - Very low engagement)
(12, 'view', 2, '2025-08-11 10:00:00'),

-- Post 13 (Carlos - Low engagement)
(13, 'view', 3, '2025-08-14 10:15:00'),
(13, 'view', 4, '2025-08-14 11:45:00'),

-- Post 14 (Diana - Good engagement)
(14, 'view', 5, '2025-08-09 16:40:00'),
(14, 'view', 6, '2025-08-09 17:00:00'),
(14, 'view', 7, '2025-08-09 18:30:00'),
(14, 'like', 5, '2025-08-09 16:45:00'),
(14, 'like', 6, '2025-08-09 17:05:00'),
(14, 'comment', 7, '2025-08-09 18:45:00'),
(14, 'share', 6, '2025-08-09 17:20:00'),

-- Post 15 (Diana - Good engagement)
(15, 'view', 8, '2025-08-13 17:10:00'),
(15, 'view', 9, '2025-08-13 17:45:00'),
(15, 'view', 10, '2025-08-13 18:00:00'),
(15, 'like', 8, '2025-08-13 17:15:00'),
(15, 'like', 9, '2025-08-13 17:50:00'),
(15, 'share', 10, '2025-08-13 18:15:00'),

-- Post 16 (Erik - Medium engagement)
(16, 'view', 11, '2025-08-16 11:00:00'),
(16, 'view', 12, '2025-08-16 12:30:00'),
(16, 'view', 13, '2025-08-16 14:00:00'),
(16, 'like', 11, '2025-08-16 11:05:00'),
(16, 'like', 12, '2025-08-16 12:35:00'),

-- Post 17 (Erik - Medium engagement)
(17, 'view', 14, '2025-08-17 11:45:00'),
(17, 'view', 15, '2025-08-17 13:00:00'),
(17, 'view', 1, '2025-08-17 14:30:00'),
(17, 'like', 14, '2025-08-17 11:50:00'),
(17, 'comment', 15, '2025-08-17 13:15:00'),

-- Post 18 (Fatima - Low engagement)
(18, 'view', 2, '2025-08-18 15:15:00'),
(18, 'view', 3, '2025-08-18 16:00:00'),
(18, 'like', 2, '2025-08-18 15:20:00'),

-- Post 19 (Fatima - Low engagement)
(19, 'view', 4, '2025-08-19 16:30:00'),
(19, 'view', 5, '2025-08-19 17:00:00'),

-- Post 20 (Grace - Highest engagement)
(20, 'view', 6, '2025-08-20 09:10:00'),
(20, 'view', 7, '2025-08-20 09:30:00'),
(20, 'view', 8, '2025-08-20 10:00:00'),
(20, 'view', 9, '2025-08-20 10:45:00'),
(20, 'view', 10, '2025-08-20 11:30:00'),
(20, 'view', 11, '2025-08-20 13:00:00'),
(20, 'like', 6, '2025-08-20 09:15:00'),
(20, 'like', 7, '2025-08-20 09:35:00'),
(20, 'like', 8, '2025-08-20 10:05:00'),
(20, 'like', 9, '2025-08-20 10:50:00'),
(20, 'comment', 7, '2025-08-20 09:40:00'),
(20, 'comment', 9, '2025-08-20 11:00:00'),
(20, 'comment', 11, '2025-08-20 13:10:00'),
(20, 'share', 8, '2025-08-20 10:10:00'),
(20, 'share', 10, '2025-08-20 11:45:00'),
(20, 'share', 11, '2025-08-20 13:20:00'),

-- Post 21 (Grace - Very high engagement)
(21, 'view', 12, '2025-08-21 10:40:00'),
(21, 'view', 13, '2025-08-21 11:00:00'),
(21, 'view', 14, '2025-08-21 11:45:00'),
(21, 'view', 15, '2025-08-21 13:30:00'),
(21, 'view', 1, '2025-08-21 14:00:00'),
(21, 'like', 12, '2025-08-21 10:45:00'),
(21, 'like', 13, '2025-08-21 11:05:00'),
(21, 'like', 14, '2025-08-21 11:50:00'),
(21, 'like', 15, '2025-08-21 13:35:00'),
(21, 'comment', 13, '2025-08-21 11:10:00'),
(21, 'comment', 14, '2025-08-21 12:00:00'),
(21, 'share', 13, '2025-08-21 11:15:00'),
(21, 'share', 15, '2025-08-21 14:00:00');
