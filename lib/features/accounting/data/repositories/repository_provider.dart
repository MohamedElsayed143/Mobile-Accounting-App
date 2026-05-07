import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
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

    final List<Invoice> _invoices = [];

    @override
    Future<void> addInvoice(Invoice invoice) async {
        _invoices.add(invoice);
    }

    @override
    Future<List<Invoice>> getInvoices({String? type}) async {
        if (type == null) return _invoices;
        return _invoices.where((inv) {
            return type == 'sale'
                ? inv.type == InvoiceType.sale
                : inv.type == InvoiceType.purchase;
        }).toList();
    }

    // أضيفي باقي الدوال المطلوبة من الـ Interface هنا
    @override
    Future<void> saveInvoice(Invoice invoice) async {
        _invoices.add(invoice);
    }
}