-- Commentary Database Schema for Local Storage
-- Supports multiple commentary sources and languages

-- Main commentaries table
CREATE TABLE commentaries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    commentary_id TEXT NOT NULL,           -- 'matthew_henry', 'john_gill', 'adam_clarke'
    book_number INTEGER NOT NULL,          -- 1-66 (Genesis=1, Revelation=66)
    book_name TEXT NOT NULL,              -- 'Genesis', '창세기'
    chapter INTEGER NOT NULL,
    verse_start INTEGER,                   -- NULL for chapter-level commentary
    verse_end INTEGER,                     -- NULL if single verse
    commentary_text TEXT NOT NULL,
    author TEXT NOT NULL,                 -- 'Matthew Henry', 'John Gill', etc.
    language TEXT NOT NULL DEFAULT 'en',  -- 'en', 'ko', 'zh', etc.
    source_url TEXT,                      -- Original download source
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Commentary metadata table
CREATE TABLE commentary_sources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    commentary_id TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    author TEXT NOT NULL,
    publication_year INTEGER,
    language TEXT NOT NULL,
    theological_perspective TEXT,          -- 'Reformed', 'Lutheran', 'Methodist'
    copyright_status TEXT,                 -- 'Public Domain', 'Copyrighted'
    download_source TEXT,
    file_format TEXT,                     -- 'JSON', 'XML', 'PDF', 'EPUB'
    total_entries INTEGER DEFAULT 0
);

-- Cross-references between commentary and Bible verses
CREATE TABLE commentary_references (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    commentary_id INTEGER,
    reference_book INTEGER NOT NULL,
    reference_chapter INTEGER NOT NULL,
    reference_verse INTEGER,
    reference_type TEXT,                  -- 'cross_ref', 'parallel', 'quote'
    FOREIGN KEY (commentary_id) REFERENCES commentaries (id)
);

-- Index for fast lookups
CREATE INDEX idx_commentaries_book_chapter ON commentaries (book_number, chapter);
CREATE INDEX idx_commentaries_verse ON commentaries (book_number, chapter, verse_start);
CREATE INDEX idx_commentaries_author ON commentaries (commentary_id, author);
CREATE INDEX idx_commentaries_language ON commentaries (language);

-- Insert initial commentary sources
INSERT INTO commentary_sources (
    commentary_id, full_name, author, publication_year, language, 
    theological_perspective, copyright_status, download_source
) VALUES
('matthew_henry_complete', 'Matthew Henry Complete Commentary', 'Matthew Henry', 1706, 'en', 'Reformed', 'Public Domain', 'bible-discovery.com'),
('matthew_henry_concise', 'Matthew Henry Concise Commentary', 'Matthew Henry', 1706, 'en', 'Reformed', 'Public Domain', 'bible-discovery.com'),
('john_gill', 'John Gill Exposition of the Entire Bible', 'John Gill', 1763, 'en', 'Reformed/Calvinist', 'Public Domain', 'bible-discovery.com'),
('adam_clarke', 'Adam Clarke Commentary on the Bible', 'Adam Clarke', 1825, 'en', 'Methodist', 'Public Domain', 'bible-discovery.com'),
('treasury_scripture', 'Treasury of Scripture Knowledge', 'R.A. Torrey', 1897, 'en', 'Evangelical', 'Public Domain', 'bible-discovery.com'),
('john_wesley', 'John Wesley Notes on the Bible', 'John Wesley', 1755, 'en', 'Methodist', 'Public Domain', 'bible-discovery.com'),
('hokmah_korean', '호크마 주석', 'Various', 2000, 'ko', 'Reformed', 'Copyrighted', 'nocr.net'),
('revival_reform_korean', '부흥과개혁사 주석 시리즈', 'Various', 2010, 'ko', 'Reformed', 'Copyrighted', 'rnrbook.com');

-- Sample data structure for commentary entries
-- INSERT INTO commentaries (
--     commentary_id, book_number, book_name, chapter, verse_start, verse_end,
--     commentary_text, author, language
-- ) VALUES (
--     'matthew_henry_complete', 1, 'Genesis', 1, 1, 1,
--     'In the beginning God created the heaven and the earth. Here we have...',
--     'Matthew Henry', 'en'
-- );