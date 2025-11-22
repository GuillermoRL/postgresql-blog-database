#!/usr/bin/env python3
"""
Generate engagement heatmap by hour and day of week.
Creates a heatmap showing when users engage most with content.
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

def fetch_engagement_patterns():
    """Fetch engagement patterns by hour and day of week"""
    query = """
    SELECT
        EXTRACT(DOW FROM engaged_timestamp) as day_of_week,
        EXTRACT(HOUR FROM engaged_timestamp) as hour,
        COUNT(*) as total_engagements,
        COUNT(*) FILTER (WHERE type = 'view') as views,
        COUNT(*) FILTER (WHERE type = 'like') as likes,
        COUNT(*) FILTER (WHERE type = 'comment') as comments,
        COUNT(*) FILTER (WHERE type = 'share') as shares
    FROM engagements
    WHERE engaged_timestamp >= NOW() - INTERVAL '90 days'
    GROUP BY
        EXTRACT(DOW FROM engaged_timestamp),
        EXTRACT(HOUR FROM engaged_timestamp)
    ORDER BY day_of_week, hour;
    """

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        df = pd.read_sql_query(query, conn)
        conn.close()
        return df
    except Exception as e:
        print(f"Error fetching data: {e}")
        sys.exit(1)

def generate_heatmap(df):
    """Generate hour x day heatmap"""
    # Convert day_of_week and hour to integers
    df['day_of_week'] = df['day_of_week'].astype(int)
    df['hour'] = df['hour'].astype(int)

    # Day names mapping (0=Sunday)
    day_names = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

    # Create pivot table for heatmap
    pivot_data = df.pivot_table(
        values='total_engagements',
        index='hour',
        columns='day_of_week',
        fill_value=0
    )

    # Rename columns to day names
    pivot_data.columns = [day_names[int(col)] for col in pivot_data.columns]

    # Reorder columns to start with Monday
    weekday_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    pivot_data = pivot_data[[col for col in weekday_order if col in pivot_data.columns]]

    # Create figure with two subplots
    fig, axes = plt.subplots(1, 2, figsize=(20, 10))

    # Heatmap 1: Total engagements
    sns.heatmap(
        pivot_data,
        annot=True,
        fmt='g',
        cmap='YlOrRd',
        cbar_kws={'label': 'Total Engagements'},
        linewidths=0.5,
        ax=axes[0]
    )
    axes[0].set_title('Engagement Heatmap: Hour × Day of Week (Last 90 Days)',
                     fontsize=16, fontweight='bold', pad=20)
    axes[0].set_xlabel('Day of Week', fontsize=12)
    axes[0].set_ylabel('Hour of Day', fontsize=12)
    axes[0].set_yticklabels([f'{int(h):02d}:00' for h in axes[0].get_yticks()], rotation=0)

    # Heatmap 2: Normalized view (percentage of daily total)
    pivot_normalized = pivot_data.div(pivot_data.sum(axis=0), axis=1) * 100

    sns.heatmap(
        pivot_normalized,
        annot=True,
        fmt='.1f',
        cmap='Blues',
        cbar_kws={'label': 'Percentage of Daily Total (%)'},
        linewidths=0.5,
        ax=axes[1]
    )
    axes[1].set_title('Engagement Distribution: % of Daily Total by Hour',
                     fontsize=16, fontweight='bold', pad=20)
    axes[1].set_xlabel('Day of Week', fontsize=12)
    axes[1].set_ylabel('Hour of Day', fontsize=12)
    axes[1].set_yticklabels([f'{int(h):02d}:00' for h in axes[1].get_yticks()], rotation=0)

    plt.tight_layout()

    # Save chart
    output_path = os.path.join(OUTPUT_DIR, 'engagement_heatmap.png')
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    print(f"✓ Heatmap saved to: {output_path}")

    # Show summary stats
    print("\n" + "="*60)
    print("ENGAGEMENT HEATMAP SUMMARY")
    print("="*60)

    # Peak engagement times
    peak_hour = df.loc[df['total_engagements'].idxmax()]
    print(f"\nPeak Engagement Time:")
    print(f"  Day: {day_names[int(peak_hour['day_of_week'])]}")
    print(f"  Hour: {int(peak_hour['hour']):02d}:00")
    print(f"  Total Engagements: {int(peak_hour['total_engagements']):,}")

    # Best days
    print(f"\nTotal Engagement by Day of Week:")
    day_totals = df.groupby('day_of_week')['total_engagements'].sum().sort_values(ascending=False)
    for day_num, total in day_totals.items():
        print(f"  {day_names[int(day_num)]}: {int(total):,} engagements")

    # Best hours (overall)
    print(f"\nTop 5 Hours (Overall):")
    hour_totals = df.groupby('hour')['total_engagements'].sum().nlargest(5)
    for hour, total in hour_totals.items():
        print(f"  {int(hour):02d}:00 - {int(hour)+1:02d}:00: {int(total):,} engagements")

    print("="*60)

if __name__ == '__main__':
    print("Generating engagement heatmap visualization...\n")
    df = fetch_engagement_patterns()

    if df.empty:
        print("No data found. Please ensure the database is populated.")
        sys.exit(1)

    generate_heatmap(df)
    print("\n✓ Visualization complete!")
