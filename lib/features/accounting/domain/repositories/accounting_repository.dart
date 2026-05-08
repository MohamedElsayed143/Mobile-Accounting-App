import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';

abstract class IAccountingRepository {
  // Accounts
  Stream<List<Account>> getAccounts();
  Future<void> addAccount(Account account);

  // Invoices
  Future<void> addInvoice(Invoice invoice);
  Stream<List<Invoice>> getInvoices({String? type});
  Future<void> saveInvoice(Invoice invoice);

  // Customers
  Stream<List<Customer>> getCustomers();
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(int id);

  // Suppliers
  Stream<List<Supplier>> getSuppliers();
  Future<void> addSupplier(Supplier supplier);
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(int id);

  // Products
  Stream<List<Product>> getProducts();
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}