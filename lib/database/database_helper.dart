import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._init();

  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('expense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // ==========================
    // Users Table
    // ==========================
    await db.execute('''
CREATE TABLE users(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
email TEXT UNIQUE NOT NULL,
password TEXT NOT NULL
)
''');

    // ==========================
    // Expenses Table
    // ==========================
    await db.execute('''
CREATE TABLE expenses(
id INTEGER PRIMARY KEY AUTOINCREMENT,
title TEXT NOT NULL,
amount REAL NOT NULL,
category TEXT NOT NULL,
date TEXT NOT NULL
)
''');

    // ==========================
    // Budget Table
    // ==========================
    await db.execute('''
CREATE TABLE budget(
id INTEGER PRIMARY KEY,
amount REAL
)
''');
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE budget(
id INTEGER PRIMARY KEY,
amount REAL
)
''');
    }
  }

  // ==========================
  // USER FUNCTIONS
  // ==========================

  Future registerUser(
    String name,
    String email,
    String password,
  ) async {
    final db = await database;

    return await db.insert(
      'users',
      {
        'name': name,
        'email': email,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> login(
    String email,
    String password,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // ==========================
  // EXPENSE FUNCTIONS
  // ==========================

  Future addExpense(
    String title,
    double amount,
    String category,
    String date,
  ) async {
    final db = await database;

    return await db.insert(
      'expenses',
      {
        'title': title,
        'amount': amount,
        'category': category,
        'date': date,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;

    return await db.query(
      'expenses',
      orderBy: 'id DESC',
    );
  }

  Future deleteExpense(int id) async {
    final db = await database;

    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future updateExpense(
    int id,
    String title,
    double amount,
    String category,
    String date,
  ) async {
    final db = await database;

    return await db.update(
      'expenses',
      {
        'title': title,
        'amount': amount,
        'category': category,
        'date': date,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================
  // BUDGET FUNCTIONS
  // ==========================

  Future<void> saveBudget(double amount) async {
    final db = await database;

    await db.insert(
      'budget',
      {
        'id': 1,
        'amount': amount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double> getBudget() async {
    final db = await database;

    final result = await db.query(
      'budget',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first['amount'] as num).toDouble();
  }
}