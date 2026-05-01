import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/presentation/widgets/invoice_dialog.dart';

abstract class AccountingState {}

class AccountingInitial extends AccountingState {}

class AccountingLoading extends AccountingState {}
class AccountAddedSuccess extends AccountingState {}
class AccountingLoaded extends AccountingState {
  final List<Account> accounts;
  AccountingLoaded(this.accounts);

  // ده بيحسب إجمالي المبيعات تلقائياً للواجهة
  double get totalSales => accounts
      .where((a) => a.name.contains('مبيعات'))
      .fold(0.0, (sum, item) => sum + item.balance);

  // ده بيحسب إجمالي المشتريات تلقائياً للواجهة
  double get totalPurchases => accounts
      .where((a) => a.name.contains('مشتريات'))
      .fold(0.0, (sum, item) => sum + item.balance);
}

class AccountingError extends AccountingState {
  final String message;
  AccountingError(this.message);
}