import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

class RepositoryProvider implements IAccountingRepository {
    // القائمة اللي بنخزن فيها الحسابات مؤقتاً
    final List<Account> _accounts = [];

    @override
    Future<List<Account>> getAccounts() async {
        return _accounts;
    }

    @override
    Future<void> addAccount(Account account) async {
        // كود الحفظ الفعلي
        _accounts.add(account);
    }

    // أضيفي باقي الدوال المطلوبة من الـ Interface هنا (مثل saveInvoice و addJournalEntry)
    @override
    Future<void> saveInvoice(dynamic invoice) async {}

    @override
    Future<void> addJournalEntry(dynamic entry) async {}
}