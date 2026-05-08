import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum InvoiceType { sale, purchase }

class InvoiceItem extends Equatable {
  final String? productId;
  final String description;
  final double quantity;
  final double price;

  const InvoiceItem({
    this.productId,
    required this.description,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toFirestore() => {
        'productId': productId,
        'description': description,
        'quantity': quantity,
        'price': price,
        'total': total,
      };

  factory InvoiceItem.fromMap(Map<String, dynamic> map) => InvoiceItem(
        productId: map['productId']?.toString() ??
            map['product_id']?.toString(),
        description: map['description'] ?? '',
        quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [productId, description, quantity, price];
}

class Invoice extends Equatable {
  final String? id;
  final String invoiceNumber;
  final String date;
  /// اسم الطرف (عميل أو مورد) للعرض
  final String partyName;
  /// معرّف العميل (فاتورة بيع)
  final String? customerId;
  /// معرّف المورد (فاتورة شراء)
  final String? supplierId;
  final List<InvoiceItem> items;
  final InvoiceType type;
  final String accountId;

  const Invoice({
    this.id,
    required this.invoiceNumber,
    required this.date,
    required this.partyName,
    this.customerId,
    this.supplierId,
    required this.items,
    required this.type,
    required this.accountId,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toFirestore() => {
        'invoiceNumber': invoiceNumber,
        'date': date,
        'partyName': partyName,
        'customerId': customerId,
        'supplierId': supplierId,
        'type': type == InvoiceType.sale ? 'sale' : 'purchase',
        'accountId': accountId,
        'totalAmount': totalAmount,
        'items': items.map((i) => i.toFirestore()).toList(),
      };

  factory Invoice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    return Invoice(
      id: doc.id,
      invoiceNumber: data['invoiceNumber'] ?? '',
      date: data['date'] ?? '',
      partyName: data['partyName'] ?? data['party_name'] ?? '',
      customerId: data['customerId']?.toString(),
      supplierId: data['supplierId']?.toString(),
      type: data['type'] == 'sale' ? InvoiceType.sale : InvoiceType.purchase,
      accountId: data['accountId']?.toString() ?? '',
      items: rawItems
          .map((e) => InvoiceItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [id, invoiceNumber, date, partyName, customerId, supplierId, items, type, accountId];
}
