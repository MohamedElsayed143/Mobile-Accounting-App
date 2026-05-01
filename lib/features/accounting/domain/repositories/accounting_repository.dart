import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/journal_entry.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';

abstract class IAccountingRepository {
  Future<List<Account>> getAccounts();
  Future<void> addJournalEntry(JournalEntry entry);
  Future<void> saveInvoice(Invoice invoice);
}
