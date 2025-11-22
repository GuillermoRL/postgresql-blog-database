-- ENUMS: More efficient than VARCHAR, stored as 4-byte integers
CREATE TYPE engagement_type AS ENUM ('view', 'like', 'comment', 'share');
CREATE TYPE user_segment_type AS ENUM ('free', 'trial', 'subscriber', 'premium');

-- ============================================================================
-- TABLES
-- ============================================================================

CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    joined_date DATE NOT NULL,
    author_category VARCHAR(100) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE posts (
    post_id SERIAL PRIMARY KEY,
    author_id INTEGER NOT NULL REFERENCES authors(author_id) ON DELETE CASCADE,
    category VARCHAR(100) NOT NULL,
    publish_timestamp TIMESTAMP NOT NULL,
    title TEXT NOT NULL,
    content_length INTEGER NOT NULL CHECK (content_length > 0),
    has_media BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT posts_publish_valid CHECK (publish_timestamp >= '2000-01-01'::timestamp)
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    signup_date DATE NOT NULL,
    country VARCHAR(2) NOT NULL,
    user_segment user_segment_type NOT NULL DEFAULT 'free',
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE engagements (
    engagement_id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
    type engagement_type NOT NULL,
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    engaged_timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE post_metadata (
    post_id INTEGER PRIMARY KEY REFERENCES posts(post_id) ON DELETE CASCADE,
    tags TEXT[] DEFAULT '{}',
    is_promoted BOOLEAN NOT NULL DEFAULT false,
    language VARCHAR(10) NOT NULL DEFAULT 'en',
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Authors indexes
CREATE INDEX idx_authors_category ON authors(author_category);
CREATE INDEX idx_authors_joined ON authors(joined_date DESC);

-- Posts indexes
CREATE INDEX idx_posts_author_publish ON posts(author_id, publish_timestamp DESC);
CREATE INDEX idx_posts_publish ON posts(publish_timestamp DESC);
CREATE INDEX idx_posts_category ON posts(category, publish_timestamp DESC);

-- Covering index: includes frequently accessed columns to avoid table lookups
CREATE INDEX idx_posts_author_covering ON posts(author_id, publish_timestamp DESC)
    INCLUDE (category, has_media, content_length);

-- Engagements indexes
CREATE INDEX idx_engagements_post ON engagements(post_id, type);
CREATE INDEX idx_engagements_timestamp ON engagements(engaged_timestamp DESC);
CREATE INDEX idx_engagements_user ON engagements(user_id, engaged_timestamp DESC);

-- Covering index for engagement aggregations (avoids heap access)
CREATE INDEX idx_engagements_post_covering ON engagements(post_id, engaged_timestamp DESC)
    INCLUDE (type, user_id);

-- Partial indexes for high-value engagements (smaller, faster)
CREATE INDEX idx_engagements_shares ON engagements(post_id, engaged_timestamp DESC)
    WHERE type = 'share';

CREATE INDEX idx_engagements_recent ON engagements(post_id, type, engaged_timestamp DESC)
    WHERE engaged_timestamp >= NOW() - INTERVAL '90 days';

-- Post metadata indexes
CREATE INDEX idx_post_metadata_tags ON post_metadata USING GIN(tags);
CREATE INDEX idx_post_metadata_promoted ON post_metadata(is_promoted)
    WHERE is_promoted = true;

-- Users indexes
CREATE INDEX idx_users_segment ON users(user_segment);
CREATE INDEX idx_users_country ON users(country);

-- Increase statistics for columns heavily used in WHERE/JOIN clauses

ALTER TABLE posts ALTER COLUMN author_id SET STATISTICS 1000;
ALTER TABLE posts ALTER COLUMN category SET STATISTICS 1000;
ALTER TABLE posts ALTER COLUMN publish_timestamp SET STATISTICS 1000;

ALTER TABLE engagements ALTER COLUMN post_id SET STATISTICS 1000;
ALTER TABLE engagements ALTER COLUMN type SET STATISTICS 500;
ALTER TABLE engagements ALTER COLUMN engaged_timestamp SET STATISTICS 1000;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TYPE engagement_type IS 'ENUM for engagement types - more efficient than VARCHAR (4 bytes vs 20 bytes)';
COMMENT ON TYPE user_segment_type IS 'ENUM for user segments - type safe and performant';
COMMENT ON INDEX idx_engagements_timestamp IS 'At 100M+ rows, partition engagements by month for optimal performance';
COMMENT ON INDEX idx_engagements_post_covering IS 'Covering index - PostgreSQL 17 B-tree optimization for multi-value lookups';
COMMENT ON INDEX idx_engagements_recent IS 'Partial index - 90% of queries target recent data, smaller index = faster scans';
  