# Engagement Visualizations

Python scripts for generating newsletter engagement analytics visualizations.

## Requirements

- Python 3.8+
- PostgreSQL database running with seed data
- Environment variables configured (or `.env` file)

## Setup

1. Install dependencies:

```bash
pip install -r requirements.txt
```

2. Configure database connection:

Create a `.env` file in the project root or set environment variables:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=newsletter_analytics
```

3. Ensure PostgreSQL is running:

```bash
docker-compose up -d
```

## Usage

Each script generates a specific visualization and saves it to the `output/` directory.

### 1. Engagement Trends Over Time

```bash
python generate_time_trends.py
```

**Output**: `output/engagement_trends.png`

**What it shows**:
- Daily engagement trends for top 5 authors (line chart)
- Daily engagement trends by category (line chart)
- Covers the last 90 days of data

**Use case**: Identify trending authors and categories, spot growth patterns

---

### 2. Engagement Heatmap

```bash
python generate_heatmap.py
```

**Output**: `output/engagement_heatmap.png`

**What it shows**:
- Hour × Day of week heatmap (absolute numbers)
- Hour × Day of week heatmap (percentage distribution)
- Highlights peak engagement times

**Use case**: Optimize publishing schedule based on when users are most active

---

### 3. Volume vs Engagement Scatter Plot

```bash
python generate_scatter.py
```

**Output**: `output/volume_vs_engagement.png`

**What it shows**:
- Scatter plot: number of posts vs average engagement per post
- Quadrants identify high performers and opportunity areas
- Category performance comparison (bar chart)
- Bubble size represents total engagement

**Use case**: Identify authors with high posting volume but low engagement (opportunity for improvement)

---

## Running All Visualizations

To generate all three charts at once:

```bash
python generate_time_trends.py && \
python generate_heatmap.py && \
python generate_scatter.py
```

Or create a simple bash script:

```bash
#!/bin/bash
echo "Generating all visualizations..."
python generate_time_trends.py
python generate_heatmap.py
python generate_scatter.py
echo "✓ All visualizations complete! Check the output/ directory."
```

## Output

All generated charts are saved in the `output/` directory:

```
output/
├── engagement_trends.png      # Time series charts
├── engagement_heatmap.png     # Hour × Day heatmaps
└── volume_vs_engagement.png   # Scatter plot + bar chart
```

## Troubleshooting

**Error: "No module named psycopg2"**
```bash
pip install psycopg2-binary
```

**Error: "Connection refused"**
- Ensure PostgreSQL is running: `docker-compose ps`
- Check connection parameters in `.env` file

**Error: "No data found"**
- Ensure seed data is loaded: Check `docker-compose` logs
- Manually load: `psql -U postgres -d newsletter_analytics -f ../database/seed_data.sql`

**Charts look empty or sparse**
- The seed data covers 90 days, but visualization scripts filter by engagement date
- Check your seed data timestamps are recent enough

## Customization

### Change Date Range

Edit the SQL query in each script. For example, change `90 days` to `30 days`:

```python
WHERE engaged_timestamp >= NOW() - INTERVAL '30 days'
```

### Adjust Chart Style

Modify chart parameters in each script:
- Figure size: `plt.rcParams['figure.figsize'] = (width, height)`
- Color scheme: `cmap='YlOrRd'` (change to any matplotlib colormap)
- DPI/resolution: `plt.savefig(..., dpi=300)`

### Export to Different Format

Change the file extension in `plt.savefig()`:
- PNG: `.png` (default, best for sharing)
- SVG: `.svg` (vector, best for editing)
- PDF: `.pdf` (vector, best for printing)

## Chart Descriptions

### Engagement Trends
Helps answer: "Which authors and categories are growing? Are there seasonal patterns?"

### Engagement Heatmap
Helps answer: "When should we publish to maximize engagement? Are weekends better than weekdays?"

### Volume vs Engagement
Helps answer: "Who's posting a lot but not getting results? Who are our star performers?"

The scatter plot uses quadrants:
- **Top-right** (green): High volume, high engagement → Star performers
- **Top-left** (yellow): Low volume, high engagement → Hidden gems
- **Bottom-right** (red): High volume, low engagement → **Opportunity area**
- **Bottom-left** (gray): Low volume, low engagement → Needs support

## Dependencies

- `psycopg2-binary`: PostgreSQL adapter for Python
- `pandas`: Data manipulation and analysis
- `matplotlib`: Core plotting library
- `seaborn`: Statistical data visualization (built on matplotlib)
- `python-dotenv`: Load environment variables from `.env` file
