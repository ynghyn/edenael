#!/bin/bash

# Commentary Download Script
# Downloads public domain Bible commentaries for local database

echo "🕊️  Bible Commentary Download Script"
echo "===================================="

# Create commentaries directory
COMMENTARY_DIR="$HOME/bible_commentaries"
mkdir -p "$COMMENTARY_DIR"
cd "$COMMENTARY_DIR"

echo "📂 Created directory: $COMMENTARY_DIR"
echo ""

# Download Public Domain Commentaries
echo "📚 Downloading Public Domain Commentaries..."
echo "--------------------------------------------"

# Matthew Henry Commentary (Internet Archive)
if [ ! -f "matthew_henry_complete.txt" ]; then
    echo "📥 Downloading Matthew Henry Complete Commentary..."
    curl -L "https://archive.org/download/MatthewHenryCompleteCommentary/Matthew%20Henry%20Complete%20Commentary.txt" -o "matthew_henry_complete.txt"
    echo "✅ Matthew Henry Complete Commentary downloaded"
else
    echo "⚠️  Matthew Henry Complete Commentary already exists"
fi

# John Gill's Exposition (if available)
if [ ! -f "john_gill_exposition.txt" ]; then
    echo "📥 Downloading John Gill's Exposition..."
    # Note: Replace with actual download URL when found
    echo "⚠️  John Gill download URL needed - check bible-discovery.com"
else
    echo "⚠️  John Gill's Exposition already exists"
fi

# Adam Clarke Commentary (if available)
if [ ! -f "adam_clarke_commentary.txt" ]; then
    echo "📥 Downloading Adam Clarke Commentary..."
    # Note: Replace with actual download URL when found
    echo "⚠️  Adam Clarke download URL needed - check bible-discovery.com"
else
    echo "⚠️  Adam Clarke Commentary already exists"
fi

echo ""

# Download Bible-Discovery commentaries (requires their software)
echo "🔧 Bible-Discovery Software Installation..."
echo "------------------------------------------"
echo "For complete commentary access, install Bible-Discovery software:"
echo "1. Visit: http://www.bible-discovery.com/"
echo "2. Download for your platform (Windows/Linux/MacOS/Android/iPhone)"
echo "3. Install and access commentaries through their interface"
echo ""

# Download from GitHub repositories
echo "🐙 Downloading from GitHub Repositories..."
echo "-----------------------------------------"

# Example commentary repositories (replace with actual URLs)
REPOS=(
    "https://github.com/tholum/webbible.git"
    # Add more repository URLs as they become available
)

for repo in "${REPOS[@]}"; do
    repo_name=$(basename "$repo" .git)
    if [ ! -d "$repo_name" ]; then
        echo "📥 Cloning $repo_name..."
        git clone "$repo" "$repo_name"
        echo "✅ $repo_name cloned successfully"
    else
        echo "⚠️  $repo_name already exists"
    fi
done

echo ""

# Setup Python environment for commentary processing
echo "🐍 Setting up Python Environment..."
echo "----------------------------------"

# Create requirements.txt
cat > requirements.txt << EOF
requests>=2.31.0
sqlite3
pathlib
lxml
beautifulsoup4
python-docx
PyPDF2
EOF

echo "✅ requirements.txt created"

# Install Python dependencies
if command -v pip &> /dev/null; then
    pip install -r requirements.txt
    echo "✅ Python dependencies installed"
else
    echo "⚠️  Python pip not found. Please install Python and pip first."
fi

echo ""

# Create database and import commentaries
echo "🗄️  Setting up Commentary Database..."
echo "------------------------------------"

# Copy the commentary scripts
cp ../commentary_database_setup.sql .
cp ../commentary_downloader.py .

# Initialize database
if command -v sqlite3 &> /dev/null; then
    sqlite3 bible_commentaries.db < commentary_database_setup.sql
    echo "✅ Commentary database initialized"
else
    echo "⚠️  SQLite3 not found. Please install SQLite3 first."
fi

# Run the Python downloader
if command -v python3 &> /dev/null; then
    python3 commentary_downloader.py
    echo "✅ Commentary downloader executed"
else
    echo "⚠️  Python3 not found. Please install Python3 first."
fi

echo ""

# Display available files
echo "📊 Downloaded Files Summary"
echo "=========================="
ls -la "$COMMENTARY_DIR"
echo ""

# Check for commentary files
echo "🔍 Commentary Files Found:"
find "$COMMENTARY_DIR" -name "*.txt" -o -name "*.json" -o -name "*.xml" | head -10
echo ""

# Usage instructions
echo "🚀 Usage Instructions"
echo "===================="
echo "1. Commentary database: $COMMENTARY_DIR/bible_commentaries.db"
echo "2. Import text files: python3 commentary_downloader.py"
echo "3. Search commentaries: Use the Python script's search function"
echo ""

echo "📝 Manual Download Sources:"
echo "- Bible-Discovery: http://www.bible-discovery.com/bible-download-commentaries.php"
echo "- Internet Archive: https://archive.org/search.php?query=bible%20commentary"
echo "- Project Gutenberg: https://www.gutenberg.org/ (search for bible commentary)"
echo ""

echo "⚠️  Copyright Notice:"
echo "- Public domain commentaries (pre-1923) are freely available"
echo "- Modern commentaries (post-1923) may be copyrighted"
echo "- Korean Reformed commentaries from 부흥과개혁사 are copyrighted"
echo "- Always respect copyright and licensing terms"
echo ""

echo "🎉 Commentary Download Setup Complete!"
echo "======================================"
echo "Next steps:"
echo "1. cd $COMMENTARY_DIR"
echo "2. python3 commentary_downloader.py"
echo "3. Import your downloaded commentary files"
echo ""
echo "Happy studying! 🙏"