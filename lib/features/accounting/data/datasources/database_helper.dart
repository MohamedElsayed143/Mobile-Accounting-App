import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/product.dart';

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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS invoice_items');
      await db.execute('DROP TABLE IF EXISTS invoices');
      await db.execute('''
        CREATE TABLE invoices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          account_id INTEGER,
          invoice_number TEXT,
          date TEXT NOT NULL,
          customer_name TEXT,
          type TEXT NOT NULL,
          total_amount REAL DEFAULT 0.0
        )
      ''');
      await db.execute('''
        CREATE TABLE invoice_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          invoice_id INTEGER NOT NULL,
          description TEXT,
          quantity REAL DEFAULT 1,
          price REAL DEFAULT 0,
          total REAL DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 4) {
      // إضافة جداول العملاء والموردين والمنتجات
      await db.execute('''
        CREATE TABLE IF NOT EXISTS customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT DEFAULT '',
          email TEXT DEFAULT '',
          address TEXT DEFAULT '',
          balance REAL DEFAULT 0.0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS suppliers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT DEFAULT '',
          email TEXT DEFAULT '',
          address TEXT DEFAULT '',
          balance REAL DEFAULT 0.0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code TEXT NOT NULL UNIQUE,
          name TEXT NOT NULL,
          buy_price REAL DEFAULT 0.0,
          sell_price REAL DEFAULT 0.0,
          quantity REAL DEFAULT 0.0
        )
      ''');
      // إضافة أعمدة الطرف (عميل/مورد) لجدول الفواتير
      try {
        await db.execute('ALTER TABLE invoices ADD COLUMN customer_id INTEGER');
        await db.execute('ALTER TABLE invoices ADD COLUMN supplier_id INTEGER');
        await db.execute('ALTER TABLE invoices ADD COLUMN party_name TEXT DEFAULT \'\'');
        await db.execute('ALTER TABLE invoice_items ADD COLUMN product_id INTEGER');
      } catch (_) {
        // الأعمدة موجودة بالفعل
      }
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
        account_id INTEGER,
        invoice_number TEXT,
        date TEXT NOT NULL,
        customer_name TEXT,
        party_name TEXT DEFAULT '',
        customer_id INTEGER,
        supplier_id INTEGER,
        type TEXT NOT NULL,
        total_amount REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        product_id INTEGER,
        description TEXT,
        quantity REAL DEFAULT 1,
        price REAL DEFAULT 0,
        total REAL DEFAULT 0
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

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT DEFAULT '',
        email TEXT DEFAULT '',
        address TEXT DEFAULT '',
        balance REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT DEFAULT '',
        email TEXT DEFAULT '',
        address TEXT DEFAULT '',
        balance REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        buy_price REAL DEFAULT 0.0,
        sell_price REAL DEFAULT 0.0,
        quantity REAL DEFAULT 0.0
      )
    ''');

    await _insertInitialAccounts(db);
  }

  // ─── Accounts ───────────────────────────────────────────────
  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
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

  // ─── Invoices ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getInvoices({String? type}) async {
    final db = await database;
    if (type != null) {
      return await db.query('invoices', where: 'type = ?', whereArgs: [type], orderBy: 'id DESC');
    }
    return await db.query('invoices', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getInvoiceItems(int invoiceId) async {
    final db = await database;
    return await db.query('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
  }

  Future<void> insertFullInvoice(
      Map<String, dynamic> invoice,
      List<Map<String, dynamic>> items,
      {bool updateStock = false}) async {
    final db = await database;
    await db.transaction((txn) async {
      int invoiceId = await txn.insert('invoices', invoice);
      for (var item in items) {
        final itemCopy = Map<String, dynamic>.from(item);
        itemCopy['invoice_id'] = invoiceId;
        await txn.insert('invoice_items', itemCopy);

        // تحديث المخزون تلقائياً
        if (updateStock && itemCopy['product_id'] != null) {
          final isSale = invoice['type'] == 'sale';
          final qty = (itemCopy['quantity'] as num).toDouble();
          final delta = isSale ? -qty : qty;
          await txn.rawUpdate(
            'UPDATE products SET quantity = quantity + ? WHERE id = ?',
            [delta, itemCopy['product_id']],
          );
        }
      }
    });
  }

  // ─── Customers ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await database;
    return await db.query('customers', orderBy: 'name ASC');
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update('customers', customer.toMap(), where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Suppliers ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final db = await database;
    return await db.query('suppliers', orderBy: 'name ASC');
  }

  Future<int> insertSupplier(Supplier supplier) async {
    final db = await database;
    return await db.insert('suppliers', supplier.toMap());
  }

  Future<int> updateSupplier(Supplier supplier) async {
    final db = await database;
    return await db.update('suppliers', supplier.toMap(), where: 'id = ?', whereArgs: [supplier.id]);
  }

  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Products ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.query('products', orderBy: 'name ASC');
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ─── User Auth ───────────────────────────────────────────────
  Future<bool> checkPhoneExists(String phone) async {
    final db = await database;
    final result = await db.query('users', where: 'phone = ?', whereArgs: [phone]);
    return result.isNotEmpty;
  }

  Future<int> registerUser(String name, String phone, String password) async {
    final db = await database;
    return await db.insert('users', {'name': name, 'phone': phone, 'password': password});
  }

  Future<Map<String, dynamic>?> loginUser(String phone, String password) async {
    final db = await database;
    final result = await db.query('users', where: 'phone = ? AND password = ?', whereArgs: [phone, password]);
    return result.isNotEmpty ? result.first : null;
  }
}