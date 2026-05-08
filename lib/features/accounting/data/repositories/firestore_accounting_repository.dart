import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

class FirestoreAccountingRepository implements IAccountingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreAccountingRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';

  CollectionReference get _accounts => _firestore.collection('users').doc(_userId).collection('accounts');
  CollectionReference get _customers => _firestore.collection('users').doc(_userId).collection('customers');
  CollectionReference get _suppliers => _firestore.collection('users').doc(_userId).collection('suppliers');
  CollectionReference get _products => _firestore.collection('users').doc(_userId).collection('products');
  CollectionReference get _invoices => _firestore.collection('users').doc(_userId).collection('invoices');

  // ─── Accounts ────────────────────────────────────────────────
  @override
  Stream<List<Account>> getAccounts() {
    return _accounts.snapshots().map(
      (s) => s.docs.map((d) => Account.fromMap(d.data() as Map<String, dynamic>, documentId: d.id)).toList(),
    );
  }

  @override
  Future<void> addAccount(Account account) async {
    await _accounts.add(account.toMap());
  }

  @override
  Future<void> updateAccount(Account account) async {
    if (account.id != null) {
      await _accounts.doc(account.id).update(account.toMap());
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _accounts.doc(id).delete();
  }

  // ─── Invoices ────────────────────────────────────────────────
  @override
  Future<void> addInvoice(Invoice invoice) async {
    await _invoices.doc(invoice.invoiceNumber).set(invoice.toMap());
  }

  @override
  Stream<List<Invoice>> getInvoices({String? type}) {
    Query query = _invoices;
    if (type != null) {
      int typeIndex = type == 'sale' ? 0 : 1;
      query = query.where('type', isEqualTo: typeIndex);
    }
    return query.snapshots().map(
      (s) => s.docs.map((d) => Invoice.fromMap(d.data() as Map<String, dynamic>, documentId: d.id)).toList(),
    );
  }

  @override
  Future<void> saveInvoice(Invoice invoice) async {
    await addInvoice(invoice);
  }

  // ─── Customers ────────────────────────────────────────────────
  @override
  Stream<List<Customer>> getCustomers() {
    return _customers.snapshots().map(
      (s) => s.docs.map((d) => Customer.fromMap(d.data() as Map<String, dynamic>, documentId: d.id)).toList(),
    );
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    await _customers.add(customer.toMap());
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    if (customer.id != null) {
      await _customers.doc(customer.id).update(customer.toMap());
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _customers.doc(id).delete();
  }

  // ─── Suppliers ────────────────────────────────────────────────
  @override
  Stream<List<Supplier>> getSuppliers() {
    return _suppliers.snapshots().map(
      (s) => s.docs.map((d) => Supplier.fromMap(d.data() as Map<String, dynamic>, documentId: d.id)).toList(),
    );
  }

  @override
  Future<void> addSupplier(Supplier supplier) async {
    await _suppliers.add(supplier.toMap());
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    if (supplier.id != null) {
      await _suppliers.doc(supplier.id).update(supplier.toMap());
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await _suppliers.doc(id).delete();
  }

  // ─── Products ────────────────────────────────────────────────
  @override
  Stream<List<Product>> getProducts() {
    return _products.snapshots().map(
      (s) => s.docs.map((d) => Product.fromMap(d.data() as Map<String, dynamic>, documentId: d.id)).toList(),
    );
  }

  @override
  Future<void> addProduct(Product product) async {
    await _products.add(product.toMap());
  }

  @override
  Future<void> updateProduct(Product product) async {
    if (product.id != null) {
      await _products.doc(product.id).update(product.toMap());
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }
}
