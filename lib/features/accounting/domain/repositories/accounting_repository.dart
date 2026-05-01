import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/journal_entry.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';

abstract class IAccountingRepository {
  // 1. جلب قائمة الحسابات
  Future<List<Account>> getAccounts();
  // 3. حفظ الفواتير
  Future<void> saveInvoice(Invoice invoice);
  Future<void> addAccount(Account account);
}