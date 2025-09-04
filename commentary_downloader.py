#!/usr/bin/env python3
"""
Commentary Downloader for Local Database
Downloads public domain Bible commentaries and stores them in local SQLite database
"""

import sqlite3
import requests
import json
import xml.etree.ElementTree as ET
from pathlib import Path
import time
from typing import Dict, List, Optional
import re

class CommentaryDownloader:
    def __init__(self, db_path: str = "bible_commentaries.db"):
        self.db_path = db_path
        self.setup_database()
    
    def setup_database(self):
        """Initialize the database with commentary schema"""
        with sqlite3.connect(self.db_path) as conn:
            # Read and execute the SQL schema
            schema_path = Path("commentary_database_setup.sql")
            if schema_path.exists():
                with open(schema_path, 'r') as f:
                    conn.executescript(f.read())
                print(f"✅ Database initialized: {self.db_path}")
            else:
                print("⚠️ Schema file not found. Please run commentary_database_setup.sql first.")
    
    def download_public_domain_commentaries(self):
        """Download available public domain commentaries"""
        
        # Matthew Henry Complete Commentary (example URL - replace with actual)
        commentaries_to_download = [
            {
                'id': 'matthew_henry_complete',
                'name': 'Matthew Henry Complete Commentary',
                'author': 'Matthew Henry',
                'url': 'https://raw.githubusercontent.com/example/matthew-henry/master/mh_complete.json',
                'format': 'json'
            },
            {
                'id': 'john_gill',
                'name': 'John Gill Exposition',
                'author': 'John Gill',
                'url': 'https://raw.githubusercontent.com/example/john-gill/master/gill_exposition.xml',
                'format': 'xml'
            }
            # Add more commentary sources as they become available
        ]
        
        for commentary in commentaries_to_download:
            print(f"📥 Downloading {commentary['name']}...")
            try:
                self.download_commentary(commentary)
                time.sleep(1)  # Be respectful to servers
            except Exception as e:
                print(f"❌ Failed to download {commentary['name']}: {e}")
    
    def download_commentary(self, commentary_info: Dict):
        """Download individual commentary and parse into database"""
        try:
            response = requests.get(commentary_info['url'], timeout=30)
            response.raise_for_status()
            
            if commentary_info['format'] == 'json':
                data = response.json()
                self.parse_json_commentary(data, commentary_info)
            elif commentary_info['format'] == 'xml':
                root = ET.fromstring(response.text)
                self.parse_xml_commentary(root, commentary_info)
            
            print(f"✅ Successfully downloaded {commentary_info['name']}")
            
        except requests.RequestException as e:
            print(f"❌ Network error downloading {commentary_info['name']}: {e}")
        except Exception as e:
            print(f"❌ Error parsing {commentary_info['name']}: {e}")
    
    def parse_json_commentary(self, data: Dict, commentary_info: Dict):
        """Parse JSON format commentary data"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            
            # Assuming JSON structure: {"books": [{"name": "Genesis", "chapters": [...]}]}
            if 'books' in data:
                for book_idx, book in enumerate(data['books'], 1):
                    book_name = book.get('name', '')
                    
                    for chapter_idx, chapter in enumerate(book.get('chapters', []), 1):
                        commentary_text = chapter.get('commentary', '')
                        
                        if commentary_text:
                            cursor.execute("""
                                INSERT INTO commentaries (
                                    commentary_id, book_number, book_name, chapter,
                                    commentary_text, author, language, source_url
                                ) VALUES (?, ?, ?, ?, ?, ?, 'en', ?)
                            """, (
                                commentary_info['id'],
                                book_idx,
                                book_name,
                                chapter_idx,
                                commentary_text,
                                commentary_info['author'],
                                commentary_info['url']
                            ))
            
            conn.commit()
    
    def parse_xml_commentary(self, root: ET.Element, commentary_info: Dict):
        """Parse XML format commentary data"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            
            # Assuming XML structure: <bible><book><chapter>...</chapter></book></bible>
            for book_elem in root.findall('.//book'):
                book_name = book_elem.get('name', '')
                book_number = int(book_elem.get('number', 0))
                
                for chapter_elem in book_elem.findall('chapter'):
                    chapter_number = int(chapter_elem.get('number', 0))
                    commentary_text = chapter_elem.text or ''
                    
                    if commentary_text.strip():
                        cursor.execute("""
                            INSERT INTO commentaries (
                                commentary_id, book_number, book_name, chapter,
                                commentary_text, author, language, source_url
                            ) VALUES (?, ?, ?, ?, ?, ?, 'en', ?)
                        """, (
                            commentary_info['id'],
                            book_number,
                            book_name,
                            chapter_number,
                            commentary_text.strip(),
                            commentary_info['author'],
                            commentary_info['url']
                        ))
            
            conn.commit()
    
    def import_from_files(self, file_path: str, commentary_id: str, author: str):
        """Import commentary from local files (PDF, TXT, etc.)"""
        path = Path(file_path)
        
        if path.suffix.lower() == '.txt':
            self.import_txt_file(path, commentary_id, author)
        elif path.suffix.lower() == '.json':
            with open(path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                commentary_info = {
                    'id': commentary_id,
                    'author': author,
                    'url': f'file://{path.absolute()}'
                }
                self.parse_json_commentary(data, commentary_info)
        else:
            print(f"⚠️ Unsupported file format: {path.suffix}")
    
    def import_txt_file(self, file_path: Path, commentary_id: str, author: str):
        """Import plain text commentary file"""
        print(f"📖 Importing text file: {file_path.name}")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Simple parsing - assumes format like "Genesis 1:1 - commentary text"
        # You'll need to adjust this based on your actual file format
        verses = re.findall(r'(\w+)\s+(\d+):(\d+)\s*[-–]\s*(.*?)(?=\n\w+\s+\d+:|\Z)', 
                           content, re.DOTALL)
        
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            
            for book_name, chapter, verse, commentary_text in verses:
                book_number = self.get_book_number(book_name)
                
                cursor.execute("""
                    INSERT INTO commentaries (
                        commentary_id, book_number, book_name, chapter, verse_start,
                        commentary_text, author, language, source_url
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, 'en', ?)
                """, (
                    commentary_id,
                    book_number,
                    book_name,
                    int(chapter),
                    int(verse),
                    commentary_text.strip(),
                    author,
                    f'file://{file_path.absolute()}'
                ))
            
            conn.commit()
            print(f"✅ Imported {len(verses)} commentary entries")
    
    def get_book_number(self, book_name: str) -> int:
        """Convert book name to number (1-66)"""
        book_mapping = {
            'Genesis': 1, 'Exodus': 2, 'Leviticus': 3, 'Numbers': 4, 'Deuteronomy': 5,
            'Joshua': 6, 'Judges': 7, 'Ruth': 8, '1Samuel': 9, '2Samuel': 10,
            # Add all 66 books...
            'Matthew': 40, 'Mark': 41, 'Luke': 42, 'John': 43, 'Acts': 44,
            'Romans': 45, '1Corinthians': 46, '2Corinthians': 47, 'Galatians': 48,
            'Ephesians': 49, 'Philippians': 50, 'Colossians': 51, '1Thessalonians': 52,
            '2Thessalonians': 53, '1Timothy': 54, '2Timothy': 55, 'Titus': 56,
            'Philemon': 57, 'Hebrews': 58, 'James': 59, '1Peter': 60, '2Peter': 61,
            '1John': 62, '2John': 63, '3John': 64, 'Jude': 65, 'Revelation': 66
        }
        return book_mapping.get(book_name, 0)
    
    def search_commentary(self, query: str, commentary_id: Optional[str] = None) -> List[Dict]:
        """Search commentary database"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            
            sql = """
                SELECT commentary_id, book_name, chapter, verse_start, 
                       commentary_text, author
                FROM commentaries 
                WHERE commentary_text LIKE ?
            """
            params = [f'%{query}%']
            
            if commentary_id:
                sql += " AND commentary_id = ?"
                params.append(commentary_id)
            
            sql += " LIMIT 50"
            
            cursor.execute(sql, params)
            results = cursor.fetchall()
            
            return [
                {
                    'commentary_id': row[0],
                    'book_name': row[1],
                    'chapter': row[2],
                    'verse': row[3],
                    'text': row[4][:200] + '...' if len(row[4]) > 200 else row[4],
                    'author': row[5]
                }
                for row in results
            ]
    
    def get_commentary_stats(self):
        """Get statistics about downloaded commentaries"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            
            cursor.execute("""
                SELECT commentary_id, author, COUNT(*) as entries
                FROM commentaries
                GROUP BY commentary_id, author
            """)
            
            results = cursor.fetchall()
            print("\n📊 Commentary Database Statistics:")
            print("-" * 50)
            
            total_entries = 0
            for row in results:
                print(f"{row[1]:<25} {row[2]:>8} entries")
                total_entries += row[2]
            
            print("-" * 50)
            print(f"{'Total':<25} {total_entries:>8} entries")

def main():
    """Main function to run the commentary downloader"""
    print("🕊️  Bible Commentary Downloader")
    print("=" * 40)
    
    downloader = CommentaryDownloader()
    
    # Example usage:
    # downloader.download_public_domain_commentaries()
    
    # Import from local files:
    # downloader.import_from_files("matthew_henry.txt", "matthew_henry_local", "Matthew Henry")
    
    # Search example:
    # results = downloader.search_commentary("faith")
    # for result in results[:3]:
    #     print(f"{result['book_name']} {result['chapter']}:{result['verse']} - {result['text']}")
    
    downloader.get_commentary_stats()
    
    print("\n✅ Commentary downloader ready!")
    print("Usage examples:")
    print("- downloader.download_public_domain_commentaries()")
    print("- downloader.import_from_files('commentary.txt', 'my_commentary', 'Author Name')")
    print("- downloader.search_commentary('faith')")

if __name__ == "__main__":
    main()