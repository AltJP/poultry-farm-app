import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('poultry_farm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Creates the database structural tables matching your research methodology
  Future _createDB(Database db, int version) async {
    // 1. Inventory Management Table
    await db.execute('''
      CREATE TABLE chickens (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        quantity INTEGER,
        status TEXT
      )
    ''');

    // 2. Egg Production Tracker Table
    await db.execute('''
      CREATE TABLE eggs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        quantity INTEGER,
        status TEXT
      )
    ''');

    // 3. Expense Tracker Table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        amount REAL,
        description TEXT
      )
    ''');

    // 4. Feeding Schedule Table
    await db.execute('''
      CREATE TABLE feeding (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        amount TEXT,
        type TEXT
      )
    ''');

    // 5. Health & Vaccination Table
    await db.execute('''
      CREATE TABLE health (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        status TEXT,
        notes TEXT
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}