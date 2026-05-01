import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/account.dart';

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        balance REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        total_amount REAL DEFAULT 0.0,
        account_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        item_name TEXT,
        total_price REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await _insertInitialAccounts(db);
  }

  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future _insertInitialAccounts(Database db) async {
    final List<Map<String, dynamic>> accountsList = [
      {'code': '1000', 'name': 'الخزينة', 'type': 0, 'balance': 0.0},
    ];
    for (var acc in accountsList) {
      await db.insert('accounts', acc);
    }
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    final db = await database;
    return await db.query('Invoices');
  }

  Future<void> insertInvoice(
      Map<String, dynamic> invoice,
      List<Map<String, dynamic>> items) async {
    final db = await database;

    await db.transaction((txn) async {
      int invoiceId = await txn.insert('invoices', invoice);

      for (var item in items) {
        item['invoice_id'] = invoiceId;
        await txn.insert('invoice_items', item);
      }
    });
  }
  // --- User Authentication Methods ---

  Future<bool> checkPhoneExists(String phone) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
    );
    return result.isNotEmpty;
  }

  Future<int> registerUser(String name, String phone, String password) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'phone': phone,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> loginUser(String phone, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'phone = ? AND password = ?',
      whereArgs: [phone, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
} // نهاية الكلاس - تأكد من وجود هذا القوس هنا فقط