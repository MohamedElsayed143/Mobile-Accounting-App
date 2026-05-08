import 'package:equatable/equatable.dart';

enum InvoiceType { sale, purchase }

class InvoiceItem extends Equatable {
  final int? productId;
  final String description;
  final double quantity;
  final double price;

  const InvoiceItem({
    this.productId,
    required this.description,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'description': description,
      'quantity': quantity,
      'price': price,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      productId: map['product_id'],
      description: map['description'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double get total => quantity * price;

  @override
  List<Object?> get props => [productId, description, quantity, price];
}

class Invoice extends Equatable {
  final String invoiceNumber;
  final String date;
  /// اسم الطرف (عميل أو مورد) للعرض
  final String partyName;
  /// معرّف العميل (فاتورة بيع)
  final int? customerId;
  /// معرّف المورد (فاتورة شراء)
  final int? supplierId;
  final List<InvoiceItem> items;
  final InvoiceType type;
  final int accountId;

  const Invoice({
    required this.invoiceNumber,
    required this.date,
    required this.partyName,
    this.customerId,
    this.supplierId,
    required this.items,
    required this.type,
    required this.accountId,
  });

  Map<String, dynamic> toMap() {
    return {
      'invoice_number': invoiceNumber,
      'date': date,
      'party_name': partyName,
      'customer_id': customerId,
      'supplier_id': supplierId,
      'type': type.index,
      'account_id': accountId,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      invoiceNumber: map['invoice_number'] ?? '',
      date: map['date'] ?? '',
      partyName: map['party_name'] ?? '',
      customerId: map['customer_id'],
      supplierId: map['supplier_id'],
      type: InvoiceType.values[map['type'] ?? 0],
      accountId: map['account_id'] ?? 0,
      items: List<InvoiceItem>.from(
        (map['items'] as List? ?? []).map((x) => InvoiceItem.fromMap(x)),
      ),
    );
  }

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  @override
  List<Object?> get props =>
      [invoiceNumber, date, partyName, customerId, supplierId, items, type, accountId];
}
