import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

class MockAccountingRepository implements IAccountingRepository {
  final List<Account> _accounts = [];
  final List<Invoice> _invoices = [];
  final List<Customer> _customers = [];
  final List<Supplier> _suppliers = [];
  final List<Product> _products = [];

  @override Stream<List<Account>> getAccounts() => Stream.value(_accounts);
  @override Future<void> addAccount(Account a) async => _accounts.add(a);
  @override Future<void> updateAccount(Account a) async {}
  @override Future<void> deleteAccount(String id) async => _accounts.removeWhere((a) => a.id == id);

  @override Future<void> addInvoice(Invoice i) async => _invoices.add(i);
  @override Stream<List<Invoice>> getInvoices({String? type}) => Stream.value(_invoices);
  @override Future<void> saveInvoice(Invoice i) async => _invoices.add(i);

  @override Stream<List<Customer>> getCustomers() => Stream.value(_customers);
  @override Future<void> addCustomer(Customer c) async => _customers.add(c);
  @override Future<void> updateCustomer(Customer c) async {}
  @override Future<void> deleteCustomer(String id) async => _customers.removeWhere((c) => c.id == id);

  @override Stream<List<Supplier>> getSuppliers() => Stream.value(_suppliers);
  @override Future<void> addSupplier(Supplier s) async => _suppliers.add(s);
  @override Future<void> updateSupplier(Supplier s) async {}
  @override Future<void> deleteSupplier(String id) async => _suppliers.removeWhere((s) => s.id == id);

  @override Stream<List<Product>> getProducts() => Stream.value(_products);
  @override Future<void> addProduct(Product p) async => _products.add(p);
  @override Future<void> updateProduct(Product p) async {}
  @override Future<void> deleteProduct(String id) async => _products.removeWhere((p) => p.id == id);
}