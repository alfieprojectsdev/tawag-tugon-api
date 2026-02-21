import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 1. The Singleton setup
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // 2. Open the connection (or create it if it doesn't exist)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tawag_tugon.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // 3. Define the Schema (Matching your Python SQLModel)
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE contacts (
      id $idType,
      name $textType,
      phone_number $textType,
      category $textType,
      priority $intType,
      protocol $textType,
      tenant_id $intType
    )
    ''');

    await db.execute('''
    CREATE TABLE news (
      id $idType,
      title $textType,
      content $textType,
      source_url TEXT,
      published_date $textType,
      tenant_id $intType,
      is_archived INTEGER DEFAULT 0
    )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create the STRICT v2 schema (NO is_archived column here)
      await db.execute('''
      CREATE TABLE news (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        source_url TEXT,
        published_date TEXT NOT NULL,
        tenant_id INTEGER NOT NULL
      )
      ''');
    }

    if (oldVersion < 3) {
      // Add is_archived column for both v1->v3 and v2->v3 upgrades
      await db.execute(
        'ALTER TABLE news ADD COLUMN is_archived INTEGER DEFAULT 0',
      );
    }
  }

  // 4. The CRUD Operations - Contacts
  Future<void> insertContact(Map<String, dynamic> contact) async {
    final db = await instance.database;
    await db.insert(
      'contacts',
      contact,
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Overwrites if ID already exists
    );
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await instance.database;
    // We order by priority descending, exactly how the API does it
    return await db.query('contacts', orderBy: 'priority DESC');
  }

  // A quick helper to wipe the table when switching LGUs
  Future<void> clearContacts() async {
    final db = await instance.database;
    await db.delete('contacts');
  }

  // 5. The CRUD Operations - News
  Future<void> insertNews(Map<String, dynamic> news) async {
    final db = await instance.database;

    // Check if the article already exists
    final existing = await db.query(
      'news',
      where:
          'source_url = ? AND source_url != ""', // Added a check to avoid matching empty URLs
      whereArgs: [news['source_url']],
    );

    if (existing.isEmpty) {
      // New article: insert it normally
      await db.insert(
        'news',
        news,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Existing article: Update the text, but DO NOT touch the 'is_archived' column
      await db.update(
        'news',
        {
          'title': news['title'],
          'content': news['content'],
          'published_date': news['published_date'],
        },
        where: 'source_url = ?',
        whereArgs: [news['source_url']],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getNews() async {
    final db = await instance.database;
    // Only fetch news that has NOT been swiped/archived
    return await db.query(
      'news',
      where: 'is_archived = 0',
      orderBy: 'published_date DESC',
    );
  }

  // Soft delete a news item
  Future<void> archiveNews(int id) async {
    final db = await instance.database;
    await db.update(
      'news',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearNews() async {
    final db = await instance.database;
    await db.delete('news');
  }
}
