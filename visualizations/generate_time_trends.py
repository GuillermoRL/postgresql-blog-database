#!/usr/bin/env python3
"""
Generate engagement trends over time by author and category.
Creates a line chart showing daily engagement trends.
"""

import os
import sys
from datetime import datetime
import psycopg2
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database connection parameters
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432'),
    'database': os.getenv('DB_NAME', 'newsletter_analytics'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'postgres')
}

# Output directory
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), 'output')
os.makedirs(OUTPUT_DIR, exist_ok=True)

def fetch_engagement_trends():
    """Fetch daily engagement trends by author and category"""
    query = """
    WITH daily_engagement AS (
        SELECT
            DATE(e.engaged_timestamp) as engagement_date,
            a.name as author_name,
            p.category,
            COUNT(*) as total_engagements,
            COUNT(*) FILTER (WHERE e.type = 'view') as views,
            COUNT(*) FILTER (WHERE e.type = 'like') as likes,
            COUNT(*) FILTER (WHERE e.type = 'comment') as comments,
            COUNT(*) FILTER (WHERE e.type = 'share') as shares
        FROM engagements e
        JOIN posts p ON e.post_id = p.post_id
        JOIN authors a ON p.author_id = a.author_id
        WHERE e.engaged_timestamp >= NOW() - INTERVAL '90 days'
        GROUP BY DATE(e.engaged_timestamp), a.name, p.category
        ORDER BY engagement_date, a.name
    )
    SELECT * FROM daily_engagement;
    """

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        df = pd.read_sql_query(query, conn)
        conn.close()
        return df
    except Exception as e:
        print(f"Error fetching data: {e}")
        sys.exit(1)

def generate_chart(df):
    """Generate engagement trends line chart"""
    # Convert date column to datetime
    df['engagement_date'] = pd.to_datetime(df['engagement_date'])

    # Set style
    sns.set_style('whitegrid')
    plt.rcParams['figure.figsize'] = (16, 10)

    # Create subplots: overall trends and by category
    fig, axes = plt.subplots(2, 1, figsize=(16, 12))

    # Chart 1: Daily engagement by author (top 5 authors)
    top_authors = df.groupby('author_name')['total_engagements'].sum().nlargest(5).index
    df_top_authors = df[df['author_name'].isin(top_authors)]

    author_daily = df_top_authors.groupby(['engagement_date', 'author_name'])['total_engagements'].sum().reset_index()

    for author in top_authors:
        author_data = author_daily[author_daily['author_name'] == author]
        axes[0].plot(author_data['engagement_date'], author_data['total_engagements'],
                    marker='o', label=author, linewidth=2, markersize=4)

    axes[0].set_title('Daily Engagement Trends - Top 5 Authors (Last 90 Days)',
                     fontsize=16, fontweight='bold', pad=20)
    axes[0].set_xlabel('Date', fontsize=12)
    axes[0].set_ylabel('Total Engagements', fontsize=12)
    axes[0].legend(loc='upper left', fontsize=10)
    axes[0].grid(True, alpha=0.3)
    axes[0].tick_params(axis='x', rotation=45)

    # Chart 2: Daily engagement by category
    category_daily = df.groupby(['engagement_date', 'category'])['total_engagements'].sum().reset_index()

    for category in df['category'].unique():
        cat_data = category_daily[category_daily['category'] == category]
        axes[1].plot(cat_data['engagement_date'], cat_data['total_engagements'],
                    marker='s', label=category, linewidth=2, markersize=4)

    axes[1].set_title('Daily Engagement Trends by Category (Last 90 Days)',
                     fontsize=16, fontweight='bold', pad=20)
    axes[1].set_xlabel('Date', fontsize=12)
    axes[1].set_ylabel('Total Engagements', fontsize=12)
    axes[1].legend(loc='upper left', fontsize=10)
    axes[1].grid(True, alpha=0.3)
    axes[1].tick_params(axis='x', rotation=45)

    plt.tight_layout()

    # Save chart
    output_path = os.path.join(OUTPUT_DIR, 'engagement_trends.png')
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    print(f"✓ Chart saved to: {output_path}")

    # Show summary stats
    print("\n" + "="*60)
    print("ENGAGEMENT TRENDS SUMMARY")
    print("="*60)
    print(f"\nDate Range: {df['engagement_date'].min()} to {df['engagement_date'].max()}")
    print(f"Total Days: {df['engagement_date'].nunique()}")
    print(f"\nTop 5 Authors by Total Engagement:")
    top_stats = df.groupby('author_name')['total_engagements'].sum().nlargest(5)
    for idx, (author, total) in enumerate(top_stats.items(), 1):
        print(f"  {idx}. {author}: {total:,} engagements")

    print(f"\nEngagement by Category:")
    cat_stats = df.groupby('category')['total_engagements'].sum().sort_values(ascending=False)
    for category, total in cat_stats.items():
        print(f"  {category}: {total:,} engagements")
    print("="*60)

if __name__ == '__main__':
    print("Generating engagement trends visualization...\n")
    df = fetch_engagement_trends()

    if df.empty:
        print("No data found. Please ensure the database is populated.")
        sys.exit(1)

    generate_chart(df)
    print("\n✓ Visualization complete!")
