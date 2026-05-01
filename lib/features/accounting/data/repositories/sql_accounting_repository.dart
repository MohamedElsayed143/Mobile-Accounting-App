import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';
import '../datasources/database_helper.dart';

class SqlAccountingRepository implements IAccountingRepository {
  final dbHelper = DatabaseHelper();

  // ✅ 1. جلب الحسابات
  @override
  Future<List<Account>> getAccounts() async {
    final db = await dbHelper.database;
    final maps = await db.query('accounts');

    return maps.map((e) => Account.fromMap(e)).toList();
  }
  @override
  Future<void> addInvoice(Invoice invoice) async {
    final db = await dbHelper.database;

    // بنستخدم transaction لضمان حفظ الفاتورة وعناصرها مع بعض أو لا شيء
    await db.transaction((txn) async {
      // 1. حفظ رأس الفاتورة في جدول invoices
      int invoiceId = await txn.insert('invoices', {
        'accountId': invoice.accountId,
        'invoiceNumber': invoice.invoiceNumber,
        'date': invoice.date,
        'customerName': invoice.customerName,
        'type': invoice.type == InvoiceType.sale ? 'sale' : 'purchase',
        'totalAmount': invoice.totalAmount,
      });

      // 2. حفظ أصناف الفاتورة في جدول منفصل (invoice_items)
      for (var item in invoice.items) {
        await txn.insert('invoice_items', {
          'invoiceId': invoiceId, // ربط الصنف بالفاتورة
          'description': item.description,
          'quantity': item.quantity,
          'price': item.price,
          'total': item.total,
        });
      }
    });
  }
  // ✅ 2. إضافة حساب
  @override
  Future<void> addAccount(Account account) async {
    final db = await dbHelper.database;
    await db.insert('accounts', account.toMap());
  }

  // ✅ 3. حفظ فاتورة + تحديث الرصيد
  @override
  Future<void> saveInvoice(Invoice invoice) async {
    final db = await dbHelper.database;

    // إدخال الفاتورة
    await db.insert('invoices', {
      'date': invoice.date,
      'total_amount': invoice.totalAmount,
      'account_id': invoice.accountId,
    });

    // حساب التغيير في الرصيد
    double amount = invoice.type == InvoiceType.sale
        ? invoice.totalAmount
        : -invoice.totalAmount;

    // تحديث رصيد الحساب
    await db.rawUpdate(
      'UPDATE accounts SET balance = balance + ? WHERE id = ?',
      [amount, invoice.accountId],
    );
  }
}