import 'package:mobile_acc/core/database/database_helper.dart';
import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/journal_entry.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

class SqlAccountingRepository implements IAccountingRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Future<List<Account>> getAccounts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return maps.map((m) => Account.fromMap(m)).toList();
  }

  @override
  Future<void> addJournalEntry(JournalEntry entry) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      int entryId = await txn.insert('journal_entries', entry.toMap());
      for (var line in entry.lines) {
        await txn.insert('transactions', {
          ...line.toMap(),
          'entry_id': entryId,
        });
        await txn.rawUpdate(
          'UPDATE accounts SET balance = balance + ? WHERE id = ?',
          [line.debit - line.credit, line.accountId]
        );
      }
    });
  }

  @override
  Future<void> saveInvoice(Invoice invoice) async {
    // For SQL, we would save the invoice table AND generate a balanced Journal Entry.
    // For this prototype, we'll focus on the accounting effect.
    final amount = invoice.totalAmount;
    
    // Construct automated journal entry based on invoice type
    final List<TransactionLine> lines = [];
    if (invoice.type == InvoiceType.sale) {
      lines.add(TransactionLine(accountId: 1, debit: amount, credit: 0.0)); // Cash
      lines.add(TransactionLine(accountId: 5, debit: 0.0, credit: amount)); // Sales
    } else {
      lines.add(TransactionLine(accountId: 6, debit: amount, credit: 0.0)); // Expenses
      lines.add(TransactionLine(accountId: 1, debit: 0.0, credit: amount)); // Cash
    }

    final entry = JournalEntry(
      date: invoice.date,
      reference: 'INV-${invoice.invoiceNumber}',
      description: 'Automated Entry for ${invoice.type == InvoiceType.sale ? "Sales" : "Purchase"} Invoice: ${invoice.invoiceNumber}',
      lines: lines,
    );

    await addJournalEntry(entry);
  }
}

IAccountingRepository getRepository() => SqlAccountingRepository();
