// Bible Database Local API Examples
// Usage examples for different Bible database formats

const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();

// Example 1: Working with JSON Bible Database (Korean)
class BibleJSON {
    constructor(filePath) {
        this.data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    }

    getVerse(bookName, chapter, verse) {
        const book = this.data.find(b => b.name === bookName);
        if (!book) return null;
        
        const chapterData = book.chapters[chapter - 1];
        if (!chapterData) return null;
        
        const verseData = chapterData.verses[verse - 1];
        return verseData ? verseData.text : null;
    }

    getChapter(bookName, chapter) {
        const book = this.data.find(b => b.name === bookName);
        if (!book) return null;
        
        const chapterData = book.chapters[chapter - 1];
        return chapterData ? chapterData.verses : null;
    }

    searchText(query) {
        const results = [];
        this.data.forEach(book => {
            book.chapters.forEach((chapter, chapterIndex) => {
                chapter.verses.forEach((verse, verseIndex) => {
                    if (verse.text.toLowerCase().includes(query.toLowerCase())) {
                        results.push({
                            book: book.name,
                            chapter: chapterIndex + 1,
                            verse: verseIndex + 1,
                            text: verse.text
                        });
                    }
                });
            });
        });
        return results;
    }
}

// Example 2: Working with SQLite Bible Database
class BibleSQLite {
    constructor(dbPath) {
        this.db = new sqlite3.Database(dbPath);
    }

    getVerse(book, chapter, verse) {
        return new Promise((resolve, reject) => {
            this.db.get(
                "SELECT text FROM bible WHERE book = ? AND chapter = ? AND verse = ?",
                [book, chapter, verse],
                (err, row) => {
                    if (err) reject(err);
                    else resolve(row ? row.text : null);
                }
            );
        });
    }

    getChapter(book, chapter) {
        return new Promise((resolve, reject) => {
            this.db.all(
                "SELECT verse, text FROM bible WHERE book = ? AND chapter = ? ORDER BY verse",
                [book, chapter],
                (err, rows) => {
                    if (err) reject(err);
                    else resolve(rows);
                }
            );
        });
    }

    searchText(query) {
        return new Promise((resolve, reject) => {
            this.db.all(
                "SELECT book, chapter, verse, text FROM bible WHERE text LIKE ? LIMIT 100",
                [`%${query}%`],
                (err, rows) => {
                    if (err) reject(err);
                    else resolve(rows);
                }
            );
        });
    }

    close() {
        this.db.close();
    }
}

// Example 3: Working with Markdown Bible Database (ESV)
class BibleMarkdown {
    constructor(basePath) {
        this.basePath = basePath;
    }

    getBookContent(bookName) {
        try {
            const filePath = `${this.basePath}/by_book/${bookName}.md`;
            return fs.readFileSync(filePath, 'utf8');
        } catch (error) {
            return null;
        }
    }

    getChapterContent(bookName, chapter) {
        try {
            const filePath = `${this.basePath}/by_chapter/${bookName}/${chapter.toString().padStart(2, '0')}.md`;
            return fs.readFileSync(filePath, 'utf8');
        } catch (error) {
            return null;
        }
    }

    parseVerse(content, verseNumber) {
        const verseRegex = new RegExp(`^${verseNumber}\\s+(.*)$`, 'm');
        const match = content.match(verseRegex);
        return match ? match[1] : null;
    }
}

// Usage Examples
async function examples() {
    console.log('=== Bible Database Examples ===\n');

    // Example 1: Korean JSON Bible
    try {
        const koreanBible = new BibleJSON('./korean_json_xml/json/ko_ko.json');
        console.log('Korean Bible (JSON):');
        const verse = koreanBible.getVerse('창세기', 1, 1);
        console.log(`창세기 1:1 - ${verse}`);
        
        const searchResults = koreanBible.searchText('하나님');
        console.log(`Found ${searchResults.length} verses containing '하나님'`);
        console.log('First result:', searchResults[0]);
    } catch (error) {
        console.log('Korean JSON Bible not found');
    }

    console.log('\n---\n');

    // Example 2: SQLite Bible (if available)
    try {
        const sqliteBible = new BibleSQLite('./korean_multi_format/formats/sqlite/bible.db');
        console.log('SQLite Bible:');
        
        const verse = await sqliteBible.getVerse(1, 1, 1);
        console.log(`Genesis 1:1 - ${verse}`);
        
        const chapter = await sqliteBible.getChapter(1, 1);
        console.log(`Genesis Chapter 1 has ${chapter.length} verses`);
        
        sqliteBible.close();
    } catch (error) {
        console.log('SQLite Bible not found');
    }

    console.log('\n---\n');

    // Example 3: ESV Markdown Bible
    try {
        const esvBible = new BibleMarkdown('./esv_markdown');
        console.log('ESV Markdown Bible:');
        
        const genesisContent = esvBible.getBookContent('Genesis');
        if (genesisContent) {
            const firstVerse = esvBible.parseVerse(genesisContent, 1);
            console.log(`Genesis 1:1 - ${firstVerse}`);
        }
        
        const chapter1 = esvBible.getChapterContent('Genesis', 1);
        if (chapter1) {
            console.log('Genesis Chapter 1 loaded successfully');
        }
    } catch (error) {
        console.log('ESV Markdown Bible not found');
    }
}

// Utility Functions
function createBibleBookIndex() {
    const books = {
        old_testament: [
            'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
            'Joshua', 'Judges', 'Ruth', '1Samuel', '2Samuel',
            '1Kings', '2Kings', '1Chronicles', '2Chronicles', 'Ezra',
            'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
            'Ecclesiastes', 'SongofSongs', 'Isaiah', 'Jeremiah', 'Lamentations',
            'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
            'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
            'Zephaniah', 'Haggai', 'Zechariah', 'Malachi'
        ],
        new_testament: [
            'Matthew', 'Mark', 'Luke', 'John', 'Acts',
            'Romans', '1Corinthians', '2Corinthians', 'Galatians', 'Ephesians',
            'Philippians', 'Colossians', '1Thessalonians', '2Thessalonians', '1Timothy',
            '2Timothy', 'Titus', 'Philemon', 'Hebrews', 'James',
            '1Peter', '2Peter', '1John', '2John', '3John',
            'Jude', 'Revelation'
        ],
        korean_books: [
            '창세기', '출애굽기', '레위기', '민수기', '신명기',
            '여호수아', '사사기', '룻기', '사무엘상', '사무엘하',
            '열왕기상', '열왕기하', '역대상', '역대하', '에스라',
            '느헤미야', '에스더', '욥기', '시편', '잠언',
            '전도서', '아가', '이사야', '예레미야', '예레미야애가',
            '에스겔', '다니엘', '호세아', '요엘', '아모스',
            '오바댜', '요나', '미가', '나훔', '하박국',
            '스바냐', '학개', '스가랴', '말라기'
        ]
    };
    
    return books;
}

// Export for use in other modules
module.exports = {
    BibleJSON,
    BibleSQLite,
    BibleMarkdown,
    createBibleBookIndex
};

// Run examples if this file is executed directly
if (require.main === module) {
    examples();
}