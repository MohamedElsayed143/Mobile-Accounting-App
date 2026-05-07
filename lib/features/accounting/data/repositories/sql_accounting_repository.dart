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

  // ✅ 2. إضافة فاتورة وحفظها في قاعدة البيانات
  @override
  Future<void> addInvoice(Invoice invoice) async {
    await dbHelper.insertFullInvoice(
      {
        'account_id': invoice.accountId,
        'invoice_number': invoice.invoiceNumber,
        'date': invoice.date,
        'customer_name': invoice.customerName,
        'type': invoice.type == InvoiceType.sale ? 'sale' : 'purchase',
        'total_amount': invoice.totalAmount,
      },
      invoice.items
          .map((item) => {
                'description': item.description,
                'quantity': item.quantity,
                'price': item.price,
                'total': item.total,
              })
          .toList(),
    );
  }

  // ✅ 3. جلب الفواتير من قاعدة البيانات
  @override
  Future<List<Invoice>> getInvoices({String? type}) async {
    final maps = await dbHelper.getInvoices(type: type);
    final List<Invoice> invoices = [];
    for (var map in maps) {
      final itemMaps = await dbHelper.getInvoiceItems(map['id'] as int);
      final items = itemMaps
          .map((i) => InvoiceItem(
                description: i['description'] ?? '',
                quantity: (i['quantity'] as num).toDouble(),
                price: (i['price'] as num).toDouble(),
              ))
          .toList();
      invoices.add(Invoice(
        invoiceNumber: map['invoice_number'] ?? '',
        date: map['date'] ?? '',
        customerName: map['customer_name'] ?? '',
        items: items,
        type: map['type'] == 'sale' ? InvoiceType.sale : InvoiceType.purchase,
        accountId: map['account_id'] ?? 0,
      ));
    }
    return invoices;
  }

  // ✅ 4. إضافة حساب جديد
  @override
  Future<void> addAccount(Account account) async {
    final db = await dbHelper.database;
    await db.insert('accounts', account.toMap());
  }

  // ✅ 5. حفظ فاتورة + تحديث الرصيد (مستخدمة للتوافق القديم)
  @override
  Future<void> saveInvoice(Invoice invoice) async {
    await addInvoice(invoice);
  }
}