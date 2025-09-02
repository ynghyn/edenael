# Bible Database Local Setup

## Repository Downloads

### 1. Korean 개역성경 (Korean Revised Version)

```bash
# Option A: scrollmapper/bible_databases (Multiple formats)
git clone https://github.com/scrollmapper/bible_databases.git
cd bible_databases/formats
# Look for KorRV files in different formats

# Option B: thiagobodruk/bible (JSON/XML)
git clone https://github.com/thiagobodruk/bible.git
cd bible
# Korean version available in JSON/XML
```

### 2. English Standard Version (ESV)

```bash
# lguenth/mdbible (Markdown format)
git clone https://github.com/lguenth/mdbible.git
cd mdbible
# ESV available in by_book/ and by_chapter/ directories
```

## Database Structure Examples

### SQLite Setup (for scrollmapper format)
```sql
CREATE TABLE bible (
    id INTEGER PRIMARY KEY,
    book INTEGER,
    chapter INTEGER,
    verse INTEGER,
    text TEXT
);

CREATE INDEX idx_book_chapter_verse ON bible(book, chapter, verse);
```

### JSON Structure (thiagobodruk format)
```json
{
  "book": {
    "id": 1,
    "name": "Genesis",
    "chapters": [
      {
        "chapter": 1,
        "verses": [
          {
            "verse": 1,
            "text": "In the beginning..."
          }
        ]
      }
    ]
  }
}
```

## Implementation Examples

### Node.js with SQLite
```javascript
const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('bible.db');

// Query verse
function getVerse(book, chapter, verse) {
    return new Promise((resolve, reject) => {
        db.get(
            "SELECT text FROM bible WHERE book = ? AND chapter = ? AND verse = ?",
            [book, chapter, verse],
            (err, row) => {
                if (err) reject(err);
                else resolve(row);
            }
        );
    });
}
```

### Python with JSON
```python
import json

def load_bible(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        return json.load(f)

def get_verse(bible_data, book_name, chapter, verse):
    for book in bible_data:
        if book['name'] == book_name:
            return book['chapters'][chapter-1]['verses'][verse-1]['text']
    return None
```

## File Locations After Clone

### scrollmapper/bible_databases
- SQLite: `formats/sqlite/`
- JSON: `formats/json/`
- CSV: `formats/csv/`
- Korean KorRV files in each format directory

### thiagobodruk/bible
- Korean JSON: `json/ko_ko.json`
- Korean XML: `xml/ko_ko.xml`

### lguenth/mdbible
- ESV by book: `by_book/Genesis.md`, `by_book/Exodus.md`, etc.
- ESV by chapter: `by_chapter/Genesis/01.md`, etc.

## Quick Start Commands

```bash
# Create local bible directory
mkdir ~/bible_databases
cd ~/bible_databases

# Download Korean databases
git clone https://github.com/scrollmapper/bible_databases.git korean_multi_format
git clone https://github.com/thiagobodruk/bible.git korean_json_xml

# Download ESV database
git clone https://github.com/lguenth/mdbible.git esv_markdown

# List available files
find . -name "*korean*" -o -name "*KorRV*" -o -name "*ko_ko*"
find . -name "*ESV*" -o -name "*.md"
```