import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

class RepositoryProvider implements IAccountingRepository {
  final List<Account> _accounts = [];
  final List<Invoice> _invoices = [];
  final List<Customer> _customers = [];
  final List<Supplier> _suppliers = [];
  final List<Product> _products = [];

  @override Stream<List<Account>> getAccounts() async* { yield _accounts; }
  @override Future<void> addAccount(Account a) async => _accounts.add(a);
  @override Future<void> addInvoice(Invoice i) async => _invoices.add(i);
  @override Future<void> saveInvoice(Invoice i) async => _invoices.add(i);
  @override Stream<List<Invoice>> getInvoices({String? type}) async* {
    if (type == null) yield _invoices;
    else yield _invoices.where((inv) => (type == 'sale') == (inv.type == InvoiceType.sale)).toList();
  }
  @override Stream<List<Customer>> getCustomers() async* { yield _customers; }
  @override Future<void> addCustomer(Customer c) async => _customers.add(c);
  @override Future<void> updateCustomer(Customer c) async {
    final i = _customers.indexWhere((x) => x.id == c.id);
    if (i >= 0) _customers[i] = c;
  }
  @override Future<void> deleteCustomer(int id) async => _customers.removeWhere((c) => c.id == id);
  @override Stream<List<Supplier>> getSuppliers() async* { yield _suppliers; }
  @override Future<void> addSupplier(Supplier s) async => _suppliers.add(s);
  @override Future<void> updateSupplier(Supplier s) async {
    final i = _suppliers.indexWhere((x) => x.id == s.id);
    if (i >= 0) _suppliers[i] = s;
  }
  @override Future<void> deleteSupplier(int id) async => _suppliers.removeWhere((s) => s.id == id);
  @override Stream<List<Product>> getProducts() async* { yield _products; }
  @override Future<void> addProduct(Product p) async => _products.add(p);
  @override Future<void> updateProduct(Product p) async {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i >= 0) _products[i] = p;
  }
  @override Future<void> deleteProduct(int id) async => _products.removeWhere((p) => p.id == id);
}