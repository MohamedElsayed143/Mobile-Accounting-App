import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/invoice.dart';

/// Firestore datasource — بديل كامل لـ SQLite DatabaseHelper
/// كل العمليات مرتبطة بـ userId لضمان عزل بيانات كل مستخدم
class FirestoreDataSource {
  static final FirestoreDataSource _instance = FirestoreDataSource._internal();
  factory FirestoreDataSource() => _instance;
  FirestoreDataSource._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// جلب userId الخاص بالمستخدم الحالي
  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('المستخدم غير مسجّل الدخول');
    return uid;
  }

  // ─── المجموعات الرئيسية ────────────────────────────────────────

  CollectionReference get _accounts =>
      _db.collection('users').doc(_uid).collection('accounts');

  CollectionReference get _customers =>
      _db.collection('users').doc(_uid).collection('customers');

  CollectionReference get _suppliers =>
      _db.collection('users').doc(_uid).collection('suppliers');

  CollectionReference get _products =>
      _db.collection('users').doc(_uid).collection('products');

  CollectionReference get _invoices =>
      _db.collection('users').doc(_uid).collection('invoices');

  // ─── Accounts ────────────────────────────────────────────────

  Future<List<Account>> getAccounts() async {
    final snap = await _accounts.orderBy('code').get();
    return snap.docs.map((d) => Account.fromFirestore(d)).toList();
  }

  Future<String> insertAccount(Account account) async {
    final ref = await _accounts.add(account.toFirestore());
    return ref.id;
  }

  Future<void> updateAccount(Account account) async {
    await _accounts.doc(account.id).update(account.toFirestore());
  }

  Future<void> deleteAccount(String id) async {
    await _accounts.doc(id).delete();
  }

  /// إضافة الحسابات الافتراضية عند أول تسجيل
  Future<void> insertInitialAccounts() async {
    final existing = await _accounts.limit(1).get();
    if (existing.docs.isNotEmpty) return; // موجودة بالفعل

    final initialAccounts = [
      Account(code: '1000', name: 'الأصول المتداولة',   type: AccountType.asset,     balance: 0.0),
      Account(code: '1100', name: 'النقدية بالصندوق',   type: AccountType.asset,     balance: 0.0),
      Account(code: '1200', name: 'البنك',               type: AccountType.asset,     balance: 0.0),
      Account(code: '2000', name: 'الالتزامات المتداولة',type: AccountType.liability, balance: 0.0),
      Account(code: '3000', name: 'حقوق الملكية',        type: AccountType.equity,    balance: 0.0),
      Account(code: '4000', name: 'الإيرادات',           type: AccountType.income,    balance: 0.0),
      Account(code: '5000', name: 'المصاريف العمومية',   type: AccountType.expense,   balance: 0.0),
    ];

    final batch = _db.batch();
    for (final acc in initialAccounts) {
      batch.set(_accounts.doc(), acc.toFirestore());
    }
    await batch.commit();
  }

  // ─── Customers ───────────────────────────────────────────────

  Future<List<Customer>> getCustomers() async {
    final snap = await _customers.orderBy('name').get();
    return snap.docs.map((d) => Customer.fromFirestore(d)).toList();
  }

  Future<String> insertCustomer(Customer customer) async {
    final ref = await _customers.add(customer.toFirestore());
    return ref.id;
  }

  Future<void> updateCustomer(Customer customer) async {
    await _customers.doc(customer.id).update(customer.toFirestore());
  }

  Future<void> deleteCustomer(String id) async {
    await _customers.doc(id).delete();
  }

  // ─── Suppliers ───────────────────────────────────────────────

  Future<List<Supplier>> getSuppliers() async {
    final snap = await _suppliers.orderBy('name').get();
    return snap.docs.map((d) => Supplier.fromFirestore(d)).toList();
  }

  Future<String> insertSupplier(Supplier supplier) async {
    final ref = await _suppliers.add(supplier.toFirestore());
    return ref.id;
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _suppliers.doc(supplier.id).update(supplier.toFirestore());
  }

  Future<void> deleteSupplier(String id) async {
    await _suppliers.doc(id).delete();
  }

  // ─── Products ────────────────────────────────────────────────

  Future<List<Product>> getProducts() async {
    final snap = await _products.orderBy('name').get();
    return snap.docs.map((d) => Product.fromFirestore(d)).toList();
  }

  Future<String> insertProduct(Product product) async {
    final ref = await _products.add(product.toFirestore());
    return ref.id;
  }

  Future<void> updateProduct(Product product) async {
    await _products.doc(product.id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  // ─── Invoices ────────────────────────────────────────────────

  Future<List<Invoice>> getInvoices({String? type}) async {
    Query query = _invoices.orderBy('date', descending: true);
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    final snap = await query.get();
    return snap.docs.map((d) => Invoice.fromFirestore(d)).toList();
  }

  /// إدراج فاتورة كاملة مع تحديث المخزون داخل Firestore Transaction
  /// يُحاكي الـ SQL Transaction لضمان الاتساق
  Future<void> insertFullInvoice(Invoice invoice) async {
    await _db.runTransaction((txn) async {
      // 1. إضافة الفاتورة
      final invoiceRef = _invoices.doc();
      txn.set(invoiceRef, invoice.toFirestore());

      // 2. تحديث المخزون لكل منتج
      for (final item in invoice.items) {
        if (item.productId == null) continue;
        final productRef = _products.doc(item.productId);
        final productSnap = await txn.get(productRef);
        if (!productSnap.exists) continue;

        final currentQty =
            (productSnap.data() as Map<String, dynamic>)['quantity'] as num? ?? 0;

        final delta = invoice.type == InvoiceType.sale
            ? -item.quantity  // بيع: نطرح من المخزون
            : item.quantity;  // شراء: نضيف إلى المخزون

        final newQty = currentQty.toDouble() + delta;
        txn.update(productRef, {'quantity': newQty});
      }
    });
  }
}
