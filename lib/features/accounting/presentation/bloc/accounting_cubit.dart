import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../../data/repositories/sql_accounting_repository.dart'; // تأكدي من المسار الصحيح للـ Sql repository
import 'accounting_state.dart';
import '../../domain/entities/invoice.dart';

class AccountingCubit extends Cubit<AccountingState> {
  final SqlAccountingRepository repository;

  AccountingCubit(this.repository) : super(AccountingInitial());

  // دالة تحميل الحسابات
  Future<void> loadAccounts() async {
    emit(AccountingLoading());
    try {
      final accounts = await repository.getAccounts(); // تم تعديل _repository إلى repository
      emit(AccountingLoaded(accounts));
    } catch (e) {
      emit(AccountingError('فشل تحميل الحسابات: $e'));
    }
  }

  // دالة إضافة فاتورة جديدة
  void addInvoice(Invoice invoice) async {
    try {
      await repository.addInvoice(invoice);
      // بعد الحفظ بننادي على loadAccounts عشان نحدث القائمة في الواجهة
      await loadAccounts();
    } catch (e) {
      debugPrint("Error adding invoice: $e");
      emit(AccountingError('فشل إضافة الفاتورة: $e'));
    }
  }

  // دالة إضافة حساب جديد
  Future<void> addNewAccount(Account newAccount) async {
    try {
      await repository.addAccount(newAccount); // تم تعديل _repository إلى repository
      emit(AccountAddedSuccess());
      await loadAccounts();
    } catch (e) {
      emit(AccountingError('فشل إضافة الحساب: $e'));
    }
  }
}