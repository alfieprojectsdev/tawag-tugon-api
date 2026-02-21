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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
  }

  // 4. The CRUD Operations
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
}
