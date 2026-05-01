import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/journal_entry.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

// States
abstract class AccountingState extends Equatable {
  const AccountingState();
  @override
  List<Object?> get props => [];
}

class AccountingInitial extends AccountingState {}
class AccountingLoading extends AccountingState {}
class AccountingLoaded extends AccountingState {
  final List<Account> accounts;
  final List<JournalEntry> entries;
  final double totalSales;
  final double totalPurchases;

  const AccountingLoaded({
    required this.accounts,
    this.entries = const [],
    this.totalSales = 0.0,
    this.totalPurchases = 0.0,
  });

  @override
  List<Object?> get props => [accounts, entries, totalSales, totalPurchases];
}
class AccountingError extends AccountingState {
  final String message;
  const AccountingError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class AccountingCubit extends Cubit<AccountingState> {
  final IAccountingRepository _repository;
  double _totalSales = 0.0;
  double _totalPurchases = 0.0;

  AccountingCubit(this._repository) : super(AccountingInitial());

  Future<void> loadAccounts() async {
    emit(AccountingLoading());
    try {
      final accounts = await _repository.getAccounts();
      emit(AccountingLoaded(
        accounts: accounts,
        totalSales: _totalSales,
        totalPurchases: _totalPurchases,
      ));
    } catch (e) {
      emit(AccountingError('فشل تحميل الحسابات: $e'));
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      await _repository.saveInvoice(invoice);
      
      // Update local totals
      if (invoice.type == InvoiceType.sale) {
        _totalSales += invoice.totalAmount;
      } else {
        _totalPurchases += invoice.totalAmount;
      }

      await loadAccounts();
    } catch (e) {
      emit(AccountingError('فشل حفظ الفاتورة: $e'));
    }
  }

  Future<void> addJournalEntry(JournalEntry entry) async {
    if (!entry.isValid) {
      emit(const AccountingError('القيد غير متوازن: مجموع المدين لا يساوي مجموع الدائن'));
      return;
    }

    try {
      await _repository.addJournalEntry(entry);
      await loadAccounts();
    } catch (e) {
      emit(AccountingError('فشل إضافة القيد: $e'));
    }
  }
}
