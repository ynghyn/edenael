#!/bin/bash

# Bible Database Download Script
# Downloads Korean 개역개정 and English ESV Bible databases from GitHub

echo "🕊️  Bible Database Setup Script"
echo "================================"

# Create bible databases directory
BIBLE_DIR="$HOME/bible_databases"
mkdir -p "$BIBLE_DIR"
cd "$BIBLE_DIR"

echo "📂 Created directory: $BIBLE_DIR"
echo ""

# Download Korean Bible Databases
echo "🇰🇷 Downloading Korean Bible Databases..."
echo "----------------------------------------"

# 1. scrollmapper/bible_databases (Multiple formats including KorRV)
if [ ! -d "korean_multi_format" ]; then
    echo "Downloading scrollmapper/bible_databases (Korean KorRV in multiple formats)..."
    git clone https://github.com/scrollmapper/bible_databases.git korean_multi_format
    echo "✅ Korean multi-format database downloaded"
else
    echo "⚠️  Korean multi-format database already exists"
fi

# 2. thiagobodruk/bible (JSON/XML Korean)
if [ ! -d "korean_json_xml" ]; then
    echo "Downloading thiagobodruk/bible (Korean JSON/XML)..."
    git clone https://github.com/thiagobodruk/bible.git korean_json_xml
    echo "✅ Korean JSON/XML database downloaded"
else
    echo "⚠️  Korean JSON/XML database already exists"
fi

echo ""

# Download English ESV Database
echo "🇺🇸 Downloading English ESV Bible Database..."
echo "--------------------------------------------"

# ESV Markdown format
if [ ! -d "esv_markdown" ]; then
    echo "Downloading lguenth/mdbible (ESV Markdown)..."
    git clone https://github.com/lguenth/mdbible.git esv_markdown
    echo "✅ ESV Markdown database downloaded"
else
    echo "⚠️  ESV Markdown database already exists"
fi

echo ""

# Additional Bible databases (optional)
echo "📚 Downloading Additional Bible Databases..."
echo "-------------------------------------------"

# godlytalias Bible Database (Multiple languages)
if [ ! -d "multilang_database" ]; then
    echo "Downloading godlytalias/Bible-Database (Multi-language)..."
    git clone https://github.com/godlytalias/Bible-Database.git multilang_database
    echo "✅ Multi-language database downloaded"
else
    echo "⚠️  Multi-language database already exists"
fi

echo ""

# Display download summary
echo "📊 Download Summary"
echo "=================="
ls -la "$BIBLE_DIR"
echo ""

# Check for Korean files
echo "🔍 Korean Bible Files Found:"
find "$BIBLE_DIR" -name "*korean*" -o -name "*KorRV*" -o -name "*ko_ko*" 2>/dev/null | head -10
echo ""

# Check for ESV files
echo "🔍 ESV Bible Files Found:"
find "$BIBLE_DIR" -name "*ESV*" -o -name "*.md" 2>/dev/null | head -10
echo ""

# Display usage instructions
echo "🚀 Usage Instructions"
echo "===================="
echo "1. Korean 개역성경 (KorRV) available in:"
echo "   - $BIBLE_DIR/korean_multi_format/formats/"
echo "   - $BIBLE_DIR/korean_json_xml/json/ko_ko.json"
echo "   - $BIBLE_DIR/korean_json_xml/xml/ko_ko.xml"
echo ""
echo "2. English ESV available in:"
echo "   - $BIBLE_DIR/esv_markdown/by_book/ (one file per book)"
echo "   - $BIBLE_DIR/esv_markdown/by_chapter/ (one file per chapter)"
echo ""
echo "3. Additional formats in:"
echo "   - $BIBLE_DIR/multilang_database/"
echo ""
echo "4. Use the bible_api_examples.js file to integrate with your application"
echo ""

# Create a simple package.json for dependencies
echo "📦 Creating package.json for Node.js dependencies..."
cat > "$BIBLE_DIR/package.json" << EOF
{
  "name": "bible-database-local",
  "version": "1.0.0",
  "description": "Local Bible databases with API examples",
  "main": "bible_api_examples.js",
  "dependencies": {
    "sqlite3": "^5.1.6"
  },
  "scripts": {
    "test": "node bible_api_examples.js",
    "install-deps": "npm install"
  },
  "keywords": ["bible", "database", "korean", "esv", "api"],
  "license": "MIT"
}
EOF

echo "✅ package.json created"
echo ""

echo "🎉 Bible Database Setup Complete!"
echo "================================="
echo "Next steps:"
echo "1. cd $BIBLE_DIR"
echo "2. npm install (to install sqlite3 dependency)"
echo "3. node bible_api_examples.js (to test the databases)"
echo ""
echo "Happy coding! 🙏"