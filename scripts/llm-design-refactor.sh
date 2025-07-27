#!/bin/bash

# FreshThreads Website Design Refactoring Script
# Uses local LLM to analyze logo and create minimalistic design

set -e

LOGO_PATH="/Users/bryanjorgensen/Documents/GitHub/FreshThreads/docs/assets/Fresh_ThreadsLLCLogo.png"
OUTPUT_DIR="design_analysis"
LLM_MODEL="dolphin-llama3:latest"

echo "🎨 FreshThreads Design Refactoring with Local LLM"
echo "=================================================="

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 1: Analyze current website structure
echo "📋 Step 1: Analyzing current website structure..."
find docs -name "*.html" -type f | head -10 > "$OUTPUT_DIR/html_files.txt"
find docs -name "*.css" -type f > "$OUTPUT_DIR/css_files.txt"

# Step 2: Create comprehensive design prompt
echo "🤖 Step 2: Creating design analysis prompt..."

cat > "$OUTPUT_DIR/design_prompt.txt" << 'EOF'
You are a professional web designer tasked with refactoring the FreshThreads LLC website into a sleek, minimalistic design.

DESIGN BRIEF:
- Company: FreshThreads LLC (Print-on-Demand Apparel)
- Style: Minimalistic, clean, bold
- Color Scheme: White and black primary (extract exact colors from logo)
- Logo Location: /docs/assets/Fresh_ThreadsLLCLogo.png
- Target: Modern, professional e-commerce aesthetic

CURRENT WEBSITE ANALYSIS NEEDED:
1. Analyze the logo design and extract the exact color palette
2. Review current HTML structure and identify design inconsistencies
3. Create a cohesive color scheme based on logo colors
4. Design a minimalistic layout that emphasizes the products
5. Ensure brand consistency across all pages

DELIVERABLES REQUESTED:
1. Color palette with exact hex codes from the logo
2. Typography recommendations (clean, modern fonts)
3. Layout structure suggestions
4. CSS framework recommendations
5. Specific design improvements for each major page section

PAGES TO REFACTOR:
- Homepage (index.html)
- Products page (products.html)
- About page (about.html)
- Contact page (contact.html)
- Account/Dashboard pages

DESIGN PRINCIPLES:
- Minimalism: Lots of white space, clean lines
- Bold: Strong typography, clear call-to-actions
- Professional: Trust-building for e-commerce
- Mobile-first: Responsive design
- Fast loading: Optimized for performance

Please provide a comprehensive design strategy that transforms this into a premium, minimalistic brand experience.
EOF

# Step 3: Analyze current CSS for color extraction
echo "🎨 Step 3: Analyzing current website colors..."
if [ -f "docs/logo.css" ]; then
    echo "Current logo CSS found:"
    cat docs/logo.css > "$OUTPUT_DIR/current_colors.txt"
fi

# Step 4: Run LLM analysis
echo "🧠 Step 4: Running LLM design analysis..."

# Create a comprehensive analysis prompt
FULL_PROMPT="$(cat << 'EOF'
# FreshThreads LLC Website Design Refactoring

## Project Overview
I need to refactor the FreshThreads LLC website (print-on-demand apparel company) into a sleek, minimalistic design using black and white as primary colors, inspired by our logo.

## Current Situation
- Website: E-commerce site for custom apparel
- Logo: Located at docs/assets/Fresh_ThreadsLLCLogo.png
- Current design: Needs modernization and cohesive branding
- Target: Clean, professional, minimalistic aesthetic

## Design Requirements
1. **Color Scheme**: Extract colors from logo, use black/white/minimal accent colors
2. **Typography**: Clean, modern, readable fonts
3. **Layout**: Minimalistic with plenty of white space
4. **Branding**: Consistent use of logo and brand elements
5. **E-commerce**: Product-focused, trust-building design

## Specific Requests
1. Analyze what colors should be extracted from the logo for the website
2. Recommend a complete color palette with hex codes
3. Suggest typography combinations
4. Provide CSS framework recommendations
5. Create layout suggestions for key pages (homepage, products, about)
6. Recommend specific improvements for navigation, headers, footers
7. Suggest product showcase design improvements

## Pages to Consider
- Homepage (main landing, hero section, featured products)
- Products page (product grid, filters, individual product pages)
- About page (company story, mission)
- Contact page (contact form, information)
- Account/Dashboard (user interface)

Please provide a comprehensive design strategy with specific recommendations I can implement.
EOF
)"

# Send to local LLM
echo "Sending design brief to local LLM..."
curl -s -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"$LLM_MODEL\",
    \"prompt\": \"$FULL_PROMPT\",
    \"stream\": false,
    \"options\": {
      \"temperature\": 0.7,
      \"top_p\": 0.9
    }
  }" | jq -r '.response' > "$OUTPUT_DIR/design_recommendations.md"

# Step 5: Display results
echo "✅ Step 5: Design analysis complete!"
echo ""
echo "📁 Results saved to: $OUTPUT_DIR/"
echo "📄 Main recommendations: $OUTPUT_DIR/design_recommendations.md"
echo ""
echo "🎨 Next steps:"
echo "1. Review the design recommendations"
echo "2. Extract color palette from recommendations"
echo "3. Implement CSS changes based on suggestions"
echo "4. Update HTML structure as recommended"
echo ""

# Display a preview of recommendations
echo "📋 Preview of recommendations:"
echo "================================"
head -50 "$OUTPUT_DIR/design_recommendations.md"
echo ""
echo "📖 View full recommendations: cat $OUTPUT_DIR/design_recommendations.md"
EOF
