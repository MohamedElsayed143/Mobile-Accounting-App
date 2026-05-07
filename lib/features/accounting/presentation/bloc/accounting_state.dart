import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';

abstract class AccountingState {}

class AccountingInitial extends AccountingState {}
class AccountingLoading extends AccountingState {}
class AccountAddedSuccess extends AccountingState {}

class AccountingLoaded extends AccountingState {
  final List<Account> accounts;
  final double totalSales;
  final double totalPurchases;
  final int customerCount;
  final int supplierCount;
  final int productCount;

  AccountingLoaded(
    this.accounts, {
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.customerCount = 0,
    this.supplierCount = 0,
    this.productCount = 0,
  });
}

class InvoicesLoaded extends AccountingState {
  final List<Invoice> invoices;
  InvoicesLoaded(this.invoices);
}

class CustomersLoaded extends AccountingState {
  final List<Customer> customers;
  CustomersLoaded(this.customers);
}

class SuppliersLoaded extends AccountingState {
  final List<Supplier> suppliers;
  SuppliersLoaded(this.suppliers);
}

class ProductsLoaded extends AccountingState {
  final List<Product> products;
  ProductsLoaded(this.products);
}

class OperationSuccess extends AccountingState {
  final String message;
  OperationSuccess(this.message);
}

class AccountingError extends AccountingState {
  final String message;
  AccountingError(this.message);
}