import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'accounting.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Accounts Table
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        balance REAL DEFAULT 0.0
      )
    ''');

    // Journal Entries Table
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        reference TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        debit REAL DEFAULT 0.0,
        credit REAL DEFAULT 0.0,
        memo TEXT,
        FOREIGN KEY (entry_id) REFERENCES journal_entries (id) ON DELETE CASCADE,
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // Optional: Initial Chart of Accounts (Arabic)
    await _insertInitialAccounts(db);
  }

  Future _insertInitialAccounts(Database db) async {
    final List<Map<String, dynamic>> accounts = [
      {'code': '1000', 'name': 'الأصول المتداولة', 'type': 0, 'balance': 0.0},
      {'code': '1100', 'name': 'النقدية بالصندوق', 'type': 0, 'balance': 0.0},
      {'code': '1200', 'name': 'البنك', 'type': 0, 'balance': 0.0},
      {'code': '2000', 'name': 'الالتزامات المتداولة', 'type': 1, 'balance': 0.0},
      {'code': '3000', 'name': 'حقوق الملكية', 'type': 2, 'balance': 0.0},
      {'code': '4000', 'name': 'الإيرادات', 'type': 3, 'balance': 0.0},
      {'code': '5000', 'name': 'المصاريف العمومية', 'type': 4, 'balance': 0.0},
    ];

    for (var account in accounts) {
      await db.insert('accounts', account);
    }
  }
}
