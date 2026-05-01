import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/journal_entry.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

class MockAccountingRepository implements IAccountingRepository {
  // In-memory state for mock data
  final List<Account> _accounts = [
    const Account(id: 1, code: '1001', name: 'الصندوق الرئيسي', type: AccountType.asset, balance: 25000.0),
    const Account(id: 2, code: '1101', name: 'البنك الأهلي', type: AccountType.asset, balance: 150000.0),
    const Account(id: 3, code: '2001', name: 'الموردون (شركة النجاح)', type: AccountType.liability, balance: -15000.0),
    const Account(id: 4, code: '3001', name: 'رأس المال', type: AccountType.equity, balance: -160000.0),
    const Account(id: 5, code: '4001', name: 'إيرادات المبيعات', type: AccountType.income, balance: 0.0),
    const Account(id: 6, code: '5001', name: 'مصاريف المكتب', type: AccountType.expense, balance: 0.0),
  ];

  @override
  Future<List<Account>> getAccounts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_accounts);
  }

  @override
  Future<void> addJournalEntry(JournalEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (var line in entry.lines) {
      _updateBalance(line.accountId, line.debit, line.credit);
    }
  }

  @override
  Future<void> saveInvoice(Invoice invoice) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final amount = invoice.totalAmount;

    if (invoice.type == InvoiceType.sale) {
      // Sales: Debit Cash (id: 1), Credit Sales Revenue (id: 5)
      _updateBalance(1, amount, 0.0);
      _updateBalance(5, 0.0, amount);
    } else {
      // Purchase: Debit Expenses (id: 6), Credit Cash (id: 1)
      _updateBalance(6, amount, 0.0);
      _updateBalance(1, 0.0, amount);
    }
  }

  void _updateBalance(int accountId, double debit, double credit) {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index != -1) {
      final account = _accounts[index];
      _accounts[index] = account.copyWith(
        balance: account.balance + (debit - credit),
      );
    }
  }
}

IAccountingRepository getRepository() => MockAccountingRepository();
