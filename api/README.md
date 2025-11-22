# Newsletter Analytics API

A NestJS-based REST API for newsletter engagement analytics with PostgreSQL 17.

## Tech Stack

- **Runtime**: Node.js 18+
- **Framework**: NestJS 11.1.9
- **Language**: TypeScript 5.9.3
- **Database**: PostgreSQL 17
- **Validation**: class-validator, class-transformer
- **Database Client**: pg (node-postgres)

## Installation

```bash
npm install
```

## Environment Variables

Create a `.env` file in the root directory:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=newsletter_analytics
PORT=3000
```

## Database Setup

Start PostgreSQL 17 with Docker:

```bash
docker-compose up -d
```

This will automatically:
- Create the database schema
- Load seed data for testing

## Running the API

Development mode with auto-reload:

```bash
npm run start:dev
```

Production mode:

```bash
npm run build
npm run start
```

The API will be available at `http://localhost:3000`

## Available Endpoints

All endpoints are prefixed with `/api/v1`

### 1. Top Authors by Engagement

```
GET /api/v1/analytics/top-authors
```

**Query Parameters:**
- `period` (optional): `30d`, `60d`, or `90d` (default: `30d`)
- `category` (optional): Filter by post category
- `limit` (optional): Number of results (1-100, default: 20)

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/analytics/top-authors?period=30d&limit=10"
```

**Example Response:**
```json
{
  "success": true,
  "data": [
    {
      "author_id": 1,
      "name": "Alice Smith",
      "category": "Technology",
      "post_count": 5,
      "total_engagement": 245,
      "weighted_score": 1830,
      "engagement_by_type": {
        "views": 150,
        "likes": 45,
        "comments": 30,
        "shares": 20
      },
      "rank": 1
    }
  ],
  "meta": {
    "period": "30d",
    "category": "all",
    "count": 10
  }
}
```

### 2. Engagement Time Patterns

```
GET /api/v1/analytics/time-patterns
```

**Query Parameters:**
- `period` (optional): `30d`, `60d`, or `90d` (default: `30d`)
- `category` (optional): Filter by post category

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/analytics/time-patterns?period=30d"
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "by_day": [
      {
        "day_of_week": 1,
        "day_name": "Monday",
        "total_engagements": 450,
        "avg_per_post": 15.2,
        "percentage_of_total": 18.5
      }
    ],
    "by_hour": [
      {
        "hour": 9,
        "total_engagements": 85,
        "avg_per_post": 12.1,
        "percentage_of_total": 8.2
      }
    ]
  },
  "meta": {
    "period": "30d",
    "category": "all"
  }
}
```

### 3. Opportunity Analysis

```
GET /api/v1/analytics/opportunity
```

**Query Parameters:**
- `period` (optional): `30d`, `60d`, or `90d` (default: `30d`)
- `minPosts` (optional): Minimum posts required (default: 3)

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/analytics/opportunity?period=30d&minPosts=3"
```

**Example Response:**
```json
{
  "success": true,
  "data": [
    {
      "author_id": 7,
      "name": "Carlos Martinez",
      "category": "Technology",
      "post_count": 8,
      "total_engagement": 320,
      "avg_engagement_per_post": 40.0,
      "engagement_percentile": 0.42,
      "volume_percentile": 0.85,
      "opportunity_score": "high_volume_low_engagement",
      "recommendation": "Focus on content quality and engagement tactics"
    }
  ],
  "meta": {
    "period": "30d",
    "minPosts": 3,
    "count": 5
  }
}
```

### 4. Author Engagement Trends

```
GET /api/v1/analytics/authors/:authorId/trends
```

**Path Parameters:**
- `authorId`: The author's ID

**Query Parameters:**
- `days` (optional): Number of days for current period (default: 7)

**Example Request:**
```bash
curl "http://localhost:3000/api/v1/analytics/authors/1/trends?days=7"
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "author_id": 1,
    "current_period": {
      "start_date": "2024-01-15",
      "end_date": "2024-01-22",
      "total_engagement": 1250
    },
    "previous_period": {
      "start_date": "2024-01-08",
      "end_date": "2024-01-15",
      "total_engagement": 980
    },
    "percent_change": 27.55,
    "breakdown_by_type": {
      "views": 800,
      "likes": 250,
      "comments": 100,
      "shares": 100
    }
  },
  "meta": {
    "days": 7
  }
}
```

## Code Quality

Lint the code:

```bash
npm run lint
npm run lint:fix
```

Format the code:

```bash
npm run format
npm run format:fix
```

## Project Structure

```
src/
├── main.ts                    # Application entry point
├── app.module.ts              # Root module
├── config/
│   └── database.config.ts     # Database configuration
├── database/
│   ├── database.module.ts     # Database module
│   └── database.service.ts    # Connection pool service
├── analytics/
│   ├── analytics.module.ts    # Analytics module
│   ├── analytics.controller.ts # HTTP endpoints
│   ├── analytics.service.ts   # Business logic
│   ├── analytics.repository.ts # Database queries
│   └── dto/
│       └── query-params.dto.ts # Request validation
└── common/
    └── filters/
        └── exception.filter.ts # Global error handling
```
