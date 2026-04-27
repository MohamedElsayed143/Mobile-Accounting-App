import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';

class MockAccountingRepository implements IAccountingRepository {
  final List<Account> _accounts = [
    Account(id: 1, code: "1001", name: 'الصندوق', type: AccountType.asset, balance: 2500.0),
    Account(id: 2, code: "1101", name: 'البنك', type: AccountType.asset, balance: 15000.0),

    Account(code: "2001", id: 3, name: 'شركة التوريدات (دائنون)', type: AccountType.liability, balance: 1200.0),

    // الإيرادات (المبيعات)
    Account(code: "4001", id: 4, name: 'مبيعات نقدية', type: AccountType.asset, balance: 15000.0),
    Account(code: "4002", id: 5, name: 'مبيعات آجلة', type: AccountType.asset, balance: 8000.0),

    // المصاريف (المشتريات)
    Account(code: "5001", id: 6, name: 'مشتريات بضاعة', type: AccountType.expense, balance: 10000.0),
    Account(code: "5101", id: 7, name: 'مصاريف كهرباء وإيجار', type: AccountType.expense, balance: 2000.0),
  ];

  @override
  Future<List<Account>> getAccounts() async => _accounts;

  @override
  Future<void> saveInvoice(Invoice invoice) async {}
  @override
  Future<void> addAccount(Account account) async {
    _accounts.add(account);
  }
}