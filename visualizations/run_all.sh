#!/bin/bash

# Generate all visualization scripts
# Usage: ./run_all.sh

echo "================================================"
echo "Generating Newsletter Engagement Visualizations"
echo "================================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    exit 1
fi

# Check if dependencies are installed
echo "Checking dependencies..."
python3 -c "import psycopg2, pandas, matplotlib, seaborn, dotenv" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Installing dependencies..."
    pip install -r requirements.txt
fi

echo ""
echo "Step 1/3: Generating engagement trends..."
python3 generate_time_trends.py

echo ""
echo "Step 2/3: Generating engagement heatmap..."
python3 generate_heatmap.py

echo ""
echo "Step 3/3: Generating volume vs engagement scatter plot..."
python3 generate_scatter.py

echo ""
echo "================================================"
echo "✓ All visualizations complete!"
echo "================================================"
echo ""
echo "Charts saved to:"
echo "  - output/engagement_trends.png"
echo "  - output/engagement_heatmap.png"
echo "  - output/volume_vs_engagement.png"
echo ""
