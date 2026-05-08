import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

/// Repository وهمي للاختبار فقط — لا يستخدم في الإنتاج
class MockAccountingRepository implements IAccountingRepository {
  final List<Account> _accounts = [
    Account(id: '1', code: "1001", name: 'الصندوق',        type: AccountType.asset,   balance: 2500.0),
    Account(id: '2', code: "1101", name: 'البنك',           type: AccountType.asset,   balance: 15000.0),
    Account(id: '4', code: "4001", name: 'مبيعات نقدية',   type: AccountType.income,  balance: 15000.0),
    Account(id: '6', code: "5001", name: 'مشتريات بضاعة',  type: AccountType.expense, balance: 10000.0),
  ];
  final List<Invoice>  _invoices  = [];
  final List<Customer> _customers = [];
  final List<Supplier> _suppliers = [];
  final List<Product>  _products  = [];

  @override Future<List<Account>> getAccounts() async => _accounts;
  @override Future<void> addAccount(Account a) async => _accounts.add(a);
  @override Future<void> updateAccount(Account a) async {
    final i = _accounts.indexWhere((x) => x.id == a.id);
    if (i >= 0) _accounts[i] = a;
  }
  @override Future<void> deleteAccount(String id) async =>
      _accounts.removeWhere((a) => a.id == id);

  @override Future<void> addInvoice(Invoice i) async => _invoices.add(i);
  @override Future<void> saveInvoice(Invoice i) async => _invoices.add(i);
  @override Future<List<Invoice>> getInvoices({String? type}) async {
    if (type == null) return _invoices;
    return _invoices.where((inv) =>
        (type == 'sale') == (inv.type == InvoiceType.sale)).toList();
  }

  @override Future<List<Customer>> getCustomers() async => _customers;
  @override Future<void> addCustomer(Customer c) async => _customers.add(c);
  @override Future<void> updateCustomer(Customer c) async {
    final i = _customers.indexWhere((x) => x.id == c.id);
    if (i >= 0) _customers[i] = c;
  }
  @override Future<void> deleteCustomer(String id) async =>
      _customers.removeWhere((c) => c.id == id);

  @override Future<List<Supplier>> getSuppliers() async => _suppliers;
  @override Future<void> addSupplier(Supplier s) async => _suppliers.add(s);
  @override Future<void> updateSupplier(Supplier s) async {
    final i = _suppliers.indexWhere((x) => x.id == s.id);
    if (i >= 0) _suppliers[i] = s;
  }
  @override Future<void> deleteSupplier(String id) async =>
      _suppliers.removeWhere((s) => s.id == id);

  @override Future<List<Product>> getProducts() async => _products;
  @override Future<void> addProduct(Product p) async => _products.add(p);
  @override Future<void> updateProduct(Product p) async {
    final i = _products.indexWhere((x) => x.id == p.id);
    if (i >= 0) _products[i] = p;
  }
  @override Future<void> deleteProduct(String id) async =>
      _products.removeWhere((p) => p.id == id);
}