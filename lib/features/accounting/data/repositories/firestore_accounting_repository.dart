import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';
import '../datasources/firestore_datasource.dart';

/// تنفيذ IAccountingRepository باستخدام Firestore
/// يحل محل SqlAccountingRepository بالكامل
class FirestoreAccountingRepository implements IAccountingRepository {
  final FirestoreDataSource _ds = FirestoreDataSource();

  // ─── Accounts ────────────────────────────────────────────────

  @override
  Future<List<Account>> getAccounts() => _ds.getAccounts();

  @override
  Future<void> addAccount(Account account) => _ds.insertAccount(account);

  @override
  Future<void> updateAccount(Account account) => _ds.updateAccount(account);

  @override
  Future<void> deleteAccount(String id) => _ds.deleteAccount(id);

  // ─── Invoices ────────────────────────────────────────────────

  @override
  Future<void> addInvoice(Invoice invoice) => _ds.insertFullInvoice(invoice);

  @override
  Future<void> saveInvoice(Invoice invoice) => _ds.insertFullInvoice(invoice);

  @override
  Future<List<Invoice>> getInvoices({String? type}) => _ds.getInvoices(type: type);

  // ─── Customers ────────────────────────────────────────────────

  @override
  Future<List<Customer>> getCustomers() => _ds.getCustomers();

  @override
  Future<void> addCustomer(Customer customer) => _ds.insertCustomer(customer);

  @override
  Future<void> updateCustomer(Customer customer) => _ds.updateCustomer(customer);

  @override
  Future<void> deleteCustomer(String id) => _ds.deleteCustomer(id);

  // ─── Suppliers ────────────────────────────────────────────────

  @override
  Future<List<Supplier>> getSuppliers() => _ds.getSuppliers();

  @override
  Future<void> addSupplier(Supplier supplier) => _ds.insertSupplier(supplier);

  @override
  Future<void> updateSupplier(Supplier supplier) => _ds.updateSupplier(supplier);

  @override
  Future<void> deleteSupplier(String id) => _ds.deleteSupplier(id);

  // ─── Products ────────────────────────────────────────────────

  @override
  Future<List<Product>> getProducts() => _ds.getProducts();

  @override
  Future<void> addProduct(Product product) => _ds.insertProduct(product);

  @override
  Future<void> updateProduct(Product product) => _ds.updateProduct(product);

  @override
  Future<void> deleteProduct(String id) => _ds.deleteProduct(id);
}
