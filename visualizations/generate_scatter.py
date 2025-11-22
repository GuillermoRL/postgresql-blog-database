#!/usr/bin/env python3
"""
Generate scatter plot: posting volume vs engagement per post.
Identifies high-performers and opportunity areas (high volume, low engagement).
"""

import os
import sys
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

def fetch_author_performance():
    """Fetch author posting volume vs engagement metrics"""
    query = """
    WITH author_stats AS (
        SELECT
            a.author_id,
            a.name as author_name,
            a.author_category as category,
            COUNT(DISTINCT p.post_id) as post_count,
            COUNT(e.engagement_id) as total_engagements,
            ROUND(COUNT(e.engagement_id)::NUMERIC / NULLIF(COUNT(DISTINCT p.post_id), 0), 2) as avg_engagement_per_post,
            COUNT(e.engagement_id) FILTER (WHERE e.type = 'view') as total_views,
            COUNT(e.engagement_id) FILTER (WHERE e.type = 'like') as total_likes,
            COUNT(e.engagement_id) FILTER (WHERE e.type = 'comment') as total_comments,
            COUNT(e.engagement_id) FILTER (WHERE e.type = 'share') as total_shares
        FROM authors a
        LEFT JOIN posts p ON a.author_id = p.author_id
            AND p.publish_timestamp >= NOW() - INTERVAL '90 days'
        LEFT JOIN engagements e ON p.post_id = e.post_id
        GROUP BY a.author_id, a.name, a.author_category
        HAVING COUNT(DISTINCT p.post_id) > 0
    )
    SELECT * FROM author_stats
    ORDER BY post_count DESC, avg_engagement_per_post DESC;
    """

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        df = pd.read_sql_query(query, conn)
        conn.close()
        return df
    except Exception as e:
        print(f"Error fetching data: {e}")
        sys.exit(1)

def generate_scatter_plot(df):
    """Generate scatter plot for volume vs engagement analysis"""
    # Set style
    sns.set_style('whitegrid')
    fig, axes = plt.subplots(1, 2, figsize=(20, 8))

    # Calculate median values for quadrant lines
    median_posts = df['post_count'].median()
    median_engagement = df['avg_engagement_per_post'].median()

    # Scatter Plot 1: Volume vs Average Engagement per Post
    scatter = axes[0].scatter(
        df['post_count'],
        df['avg_engagement_per_post'],
        s=df['total_engagements'],  # Size by total engagement
        c=df['category'].astype('category').cat.codes,  # Color by category
        cmap='tab10',
        alpha=0.6,
        edgecolors='black',
        linewidth=1
    )

    # Add quadrant lines
    axes[0].axvline(median_posts, color='red', linestyle='--', alpha=0.5, linewidth=1.5, label='Median Posts')
    axes[0].axhline(median_engagement, color='blue', linestyle='--', alpha=0.5, linewidth=1.5, label='Median Engagement')

    # Add labels for each point
    for idx, row in df.iterrows():
        axes[0].annotate(
            row['author_name'],
            (row['post_count'], row['avg_engagement_per_post']),
            xytext=(5, 5),
            textcoords='offset points',
            fontsize=8,
            alpha=0.7
        )

    # Add quadrant labels
    max_posts = df['post_count'].max()
    max_engagement = df['avg_engagement_per_post'].max()

    axes[0].text(median_posts * 1.5, max_engagement * 0.95, 'High Volume\nHigh Engagement',
                ha='center', va='top', fontsize=10, bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))
    axes[0].text(median_posts * 0.5, max_engagement * 0.95, 'Low Volume\nHigh Engagement',
                ha='center', va='top', fontsize=10, bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))
    axes[0].text(median_posts * 1.5, median_engagement * 0.3, 'High Volume\nLow Engagement\n(OPPORTUNITY)',
                ha='center', va='top', fontsize=10, bbox=dict(boxstyle='round', facecolor='lightcoral', alpha=0.5))
    axes[0].text(median_posts * 0.5, median_engagement * 0.3, 'Low Volume\nLow Engagement',
                ha='center', va='top', fontsize=10, bbox=dict(boxstyle='round', facecolor='lightgray', alpha=0.5))

    axes[0].set_title('Author Performance: Posting Volume vs Engagement Rate (Last 90 Days)',
                     fontsize=14, fontweight='bold', pad=20)
    axes[0].set_xlabel('Number of Posts', fontsize=12)
    axes[0].set_ylabel('Average Engagement per Post', fontsize=12)
    axes[0].legend(loc='upper left', fontsize=9)
    axes[0].grid(True, alpha=0.3)

    # Scatter Plot 2: Category comparison
    category_stats = df.groupby('category').agg({
        'post_count': 'sum',
        'total_engagements': 'sum',
        'avg_engagement_per_post': 'mean'
    }).reset_index()

    bars = axes[1].bar(
        category_stats['category'],
        category_stats['avg_engagement_per_post'],
        color=sns.color_palette('tab10', len(category_stats)),
        alpha=0.7,
        edgecolor='black'
    )

    # Add value labels on bars
    for bar, val in zip(bars, category_stats['avg_engagement_per_post']):
        height = bar.get_height()
        axes[1].text(bar.get_x() + bar.get_width()/2., height,
                    f'{val:.1f}',
                    ha='center', va='bottom', fontsize=10, fontweight='bold')

    axes[1].set_title('Average Engagement per Post by Category',
                     fontsize=14, fontweight='bold', pad=20)
    axes[1].set_xlabel('Category', fontsize=12)
    axes[1].set_ylabel('Average Engagement per Post', fontsize=12)
    axes[1].tick_params(axis='x', rotation=45)
    axes[1].grid(True, axis='y', alpha=0.3)

    plt.tight_layout()

    # Save chart
    output_path = os.path.join(OUTPUT_DIR, 'volume_vs_engagement.png')
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    print(f"✓ Scatter plot saved to: {output_path}")

    # Show summary stats
    print("\n" + "="*60)
    print("VOLUME VS ENGAGEMENT ANALYSIS")
    print("="*60)

    # Identify quadrants
    high_volume_low_engagement = df[
        (df['post_count'] > median_posts) &
        (df['avg_engagement_per_post'] < median_engagement)
    ]

    high_performers = df[
        (df['post_count'] > median_posts) &
        (df['avg_engagement_per_post'] > median_engagement)
    ]

    print(f"\nMedian Metrics:")
    print(f"  Posts: {median_posts:.0f}")
    print(f"  Avg Engagement/Post: {median_engagement:.1f}")

    print(f"\n🔴 OPPORTUNITY AUTHORS (High Volume, Low Engagement):")
    if not high_volume_low_engagement.empty:
        for _, author in high_volume_low_engagement.iterrows():
            print(f"  • {author['author_name']} ({author['category']})")
            print(f"    Posts: {int(author['post_count'])}, Avg Engagement: {author['avg_engagement_per_post']:.1f}")
    else:
        print("  None found")

    print(f"\n🟢 HIGH PERFORMERS (High Volume, High Engagement):")
    if not high_performers.empty:
        for _, author in high_performers.iterrows():
            print(f"  • {author['author_name']} ({author['category']})")
            print(f"    Posts: {int(author['post_count'])}, Avg Engagement: {author['avg_engagement_per_post']:.1f}")
    else:
        print("  None found")

    print(f"\nCategory Performance:")
    for _, cat in category_stats.iterrows():
        print(f"  {cat['category']}: {cat['avg_engagement_per_post']:.1f} avg engagement/post")

    print("="*60)

if __name__ == '__main__':
    print("Generating volume vs engagement scatter plot...\n")
    df = fetch_author_performance()

    if df.empty:
        print("No data found. Please ensure the database is populated.")
        sys.exit(1)

    generate_scatter_plot(df)
    print("\n✓ Visualization complete!")
