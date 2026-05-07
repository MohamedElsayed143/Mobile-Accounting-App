import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';

abstract class IAccountingRepository {
  Future<List<Account>> getAccounts();
  Future<void> addInvoice(Invoice invoice);
  Future<List<Invoice>> getInvoices({String? type});
  Future<void> saveInvoice(Invoice invoice);
  Future<void> addAccount(Account account);
}