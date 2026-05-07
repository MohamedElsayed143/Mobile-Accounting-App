import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';

abstract class AccountingState {}

class AccountingInitial extends AccountingState {}

class AccountingLoading extends AccountingState {}

class AccountAddedSuccess extends AccountingState {}

class AccountingLoaded extends AccountingState {
  final List<Account> accounts;
  AccountingLoaded(this.accounts);

  double get totalSales => accounts
      .where((a) => a.name.contains('مبيعات'))
      .fold(0.0, (sum, item) => sum + item.balance);

  double get totalPurchases => accounts
      .where((a) => a.name.contains('مشتريات'))
      .fold(0.0, (sum, item) => sum + item.balance);
}

class InvoicesLoaded extends AccountingState {
  final List<Invoice> invoices;
  InvoicesLoaded(this.invoices);
}

class AccountingError extends AccountingState {
  final String message;
  AccountingError(this.message);
}