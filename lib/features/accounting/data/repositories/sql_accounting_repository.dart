import 'package:mobile_acc/features/accounting/domain/entities/account.dart';
import 'package:mobile_acc/features/accounting/domain/entities/invoice.dart';
import 'package:mobile_acc/features/accounting/domain/entities/customer.dart';
import 'package:mobile_acc/features/accounting/domain/entities/supplier.dart';
import 'package:mobile_acc/features/accounting/domain/entities/product.dart';
import 'package:mobile_acc/features/accounting/domain/repositories/accounting_repository.dart';
import '../datasources/database_helper.dart';

class SqlAccountingRepository implements IAccountingRepository {
  final dbHelper = DatabaseHelper();

  // ─── Accounts ────────────────────────────────────────────────
  @override
  Future<List<Account>> getAccounts() async {
    final db = await dbHelper.database;
    final maps = await db.query('accounts');
    return maps.map((e) => Account.fromMap(e)).toList();
  }

  @override
  Future<void> addAccount(Account account) async {
    final db = await dbHelper.database;
    await db.insert('accounts', account.toMap());
  }

  // ─── Invoices ────────────────────────────────────────────────
  @override
  Future<void> addInvoice(Invoice invoice) async {
    await dbHelper.insertFullInvoice(
      {
        'account_id': invoice.accountId,
        'invoice_number': invoice.invoiceNumber,
        'date': invoice.date,
        'customer_name': invoice.partyName,
        'party_name': invoice.partyName,
        'customer_id': invoice.customerId,
        'supplier_id': invoice.supplierId,
        'type': invoice.type == InvoiceType.sale ? 'sale' : 'purchase',
        'total_amount': invoice.totalAmount,
      },
      invoice.items
          .map((item) => {
                'product_id': item.productId,
                'description': item.description,
                'quantity': item.quantity,
                'price': item.price,
                'total': item.total,
              })
          .toList(),
      updateStock: true,
    );
  }

  @override
  Future<List<Invoice>> getInvoices({String? type}) async {
    final maps = await dbHelper.getInvoices(type: type);
    final List<Invoice> invoices = [];
    for (var map in maps) {
      final itemMaps = await dbHelper.getInvoiceItems(map['id'] as int);
      final items = itemMaps
          .map((i) => InvoiceItem(
                productId: i['product_id'] as int?,
                description: i['description'] ?? '',
                quantity: (i['quantity'] as num).toDouble(),
                price: (i['price'] as num).toDouble(),
              ))
          .toList();
      invoices.add(Invoice(
        invoiceNumber: map['invoice_number'] ?? '',
        date: map['date'] ?? '',
        partyName: map['party_name'] ?? map['customer_name'] ?? '',
        customerId: map['customer_id'] as int?,
        supplierId: map['supplier_id'] as int?,
        items: items,
        type: map['type'] == 'sale' ? InvoiceType.sale : InvoiceType.purchase,
        accountId: map['account_id'] ?? 0,
      ));
    }
    return invoices;
  }

  @override
  Future<void> saveInvoice(Invoice invoice) async => addInvoice(invoice);

  // ─── Customers ────────────────────────────────────────────────
  @override
  Future<List<Customer>> getCustomers() async {
    final maps = await dbHelper.getCustomers();
    return maps.map((e) => Customer.fromMap(e)).toList();
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    await dbHelper.insertCustomer(customer);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await dbHelper.updateCustomer(customer);
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await dbHelper.deleteCustomer(id);
  }

  // ─── Suppliers ────────────────────────────────────────────────
  @override
  Future<List<Supplier>> getSuppliers() async {
    final maps = await dbHelper.getSuppliers();
    return maps.map((e) => Supplier.fromMap(e)).toList();
  }

  @override
  Future<void> addSupplier(Supplier supplier) async {
    await dbHelper.insertSupplier(supplier);
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    await dbHelper.updateSupplier(supplier);
  }

  @override
  Future<void> deleteSupplier(int id) async {
    await dbHelper.deleteSupplier(id);
  }

  // ─── Products ────────────────────────────────────────────────
  @override
  Future<List<Product>> getProducts() async {
    final maps = await dbHelper.getProducts();
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  @override
  Future<void> addProduct(Product product) async {
    await dbHelper.insertProduct(product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    await dbHelper.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await dbHelper.deleteProduct(id);
  }
}