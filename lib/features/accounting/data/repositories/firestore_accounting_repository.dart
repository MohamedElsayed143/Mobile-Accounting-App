import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

class FirestoreAccountingRepository implements IAccountingRepository {
  final FirebaseFirestore _firestore;

  FirestoreAccountingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Accounts ────────────────────────────────────────────────
  @override
  Stream<List<Account>> getAccounts() {
    return _firestore.collection('accounts').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Account.fromMap(doc.data())).toList(),
    );
  }

  @override
  Future<void> addAccount(Account account) async {
    // If account has an ID (e.g. from local DB), use it as document ID
    if (account.id != null) {
      await _firestore.collection('accounts').doc(account.id.toString()).set(account.toMap());
    } else {
      await _firestore.collection('accounts').add(account.toMap());
    }
  }

  // ─── Invoices ────────────────────────────────────────────────
  @override
  Future<void> addInvoice(Invoice invoice) async {
    // Since Invoice doesn't have an ID field in the provided entity, we use its invoiceNumber
    await _firestore.collection('invoices').doc(invoice.invoiceNumber).set(invoice.toMap());
  }

  @override
  Stream<List<Invoice>> getInvoices({String? type}) {
    Query query = _firestore.collection('invoices');
    if (type != null) {
      int typeIndex = type == 'sale' ? 0 : 1;
      query = query.where('type', isEqualTo: typeIndex);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<void> saveInvoice(Invoice invoice) async {
    await addInvoice(invoice);
  }

  // ─── Customers ────────────────────────────────────────────────
  @override
  Stream<List<Customer>> getCustomers() {
    return _firestore.collection('customers').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Customer.fromMap(doc.data())).toList(),
    );
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    if (customer.id != null) {
      await _firestore.collection('customers').doc(customer.id.toString()).set(customer.toMap());
    } else {
      await _firestore.collection('customers').add(customer.toMap());
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    if (customer.id != null) {
      await _firestore.collection('customers').doc(customer.id.toString()).update(customer.toMap());
    }
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await _firestore.collection('customers').doc(id.toString()).delete();
  }

  // ─── Suppliers ────────────────────────────────────────────────
  @override
  Stream<List<Supplier>> getSuppliers() {
    return _firestore.collection('suppliers').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Supplier.fromMap(doc.data())).toList(),
    );
  }

  @override
  Future<void> addSupplier(Supplier supplier) async {
    if (supplier.id != null) {
      await _firestore.collection('suppliers').doc(supplier.id.toString()).set(supplier.toMap());
    } else {
      await _firestore.collection('suppliers').add(supplier.toMap());
    }
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    if (supplier.id != null) {
      await _firestore.collection('suppliers').doc(supplier.id.toString()).update(supplier.toMap());
    }
  }

  @override
  Future<void> deleteSupplier(int id) async {
    await _firestore.collection('suppliers').doc(id.toString()).delete();
  }

  // ─── Products ────────────────────────────────────────────────
  @override
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList(),
    );
  }

  @override
  Future<void> addProduct(Product product) async {
    if (product.id != null) {
      await _firestore.collection('products').doc(product.id.toString()).set(product.toMap());
    } else {
      await _firestore.collection('products').add(product.toMap());
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    if (product.id != null) {
      await _firestore.collection('products').doc(product.id.toString()).update(product.toMap());
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _firestore.collection('products').doc(id.toString()).delete();
  }
}
