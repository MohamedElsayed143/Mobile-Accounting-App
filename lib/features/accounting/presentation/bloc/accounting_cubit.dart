import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../../data/repositories/sql_accounting_repository.dart';
import 'accounting_state.dart';
import '../../domain/entities/invoice.dart';

class AccountingCubit extends Cubit<AccountingState> {
  final SqlAccountingRepository repository;

  AccountingCubit(this.repository) : super(AccountingInitial());

  // دالة تحميل الحسابات
  Future<void> loadAccounts() async {
    emit(AccountingLoading());
    try {
      final accounts = await repository.getAccounts();
      emit(AccountingLoaded(accounts));
    } catch (e) {
      emit(AccountingError('فشل تحميل الحسابات: $e'));
    }
  }

  // دالة إضافة فاتورة جديدة
  Future<void> addInvoice(Invoice invoice) async {
    try {
      await repository.addInvoice(invoice);
      debugPrint("✅ تم حفظ الفاتورة بنجاح");
    } catch (e) {
      debugPrint("❌ Error adding invoice: $e");
      emit(AccountingError('فشل إضافة الفاتورة: $e'));
    }
  }

  // دالة جلب الفواتير (بيع أو شراء)
  Future<void> loadInvoices({String? type}) async {
    emit(AccountingLoading());
    try {
      final invoices = await repository.getInvoices(type: type);
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(AccountingError('فشل تحميل الفواتير: $e'));
    }
  }

  // دالة إضافة حساب جديد
  Future<void> addNewAccount(Account newAccount) async {
    try {
      await repository.addAccount(newAccount);
      emit(AccountAddedSuccess());
      await loadAccounts();
    } catch (e) {
      emit(AccountingError('فشل إضافة الحساب: $e'));
    }
  }
}