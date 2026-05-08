import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';

abstract class IAccountingRepository {
  // Accounts
  Future<List<Account>> getAccounts();
  Future<void> addAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);

  // Invoices
  Future<void> addInvoice(Invoice invoice);
  Future<List<Invoice>> getInvoices({String? type});
  Future<void> saveInvoice(Invoice invoice);

  // Customers
  Future<List<Customer>> getCustomers();
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);

  // Suppliers
  Future<List<Supplier>> getSuppliers();
  Future<void> addSupplier(Supplier supplier);
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(String id);

  // Products
  Future<List<Product>> getProducts();
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}