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

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'description': description,
        'quantity': quantity,
        'price': price,
      };

  factory InvoiceItem.fromMap(Map<String, dynamic> map) => InvoiceItem(
        productId: map['productId']?.toString(),
        description: map['description'] ?? '',
        quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [productId, description, quantity, price];
}

class Invoice extends Equatable {
  final String? id;
  final String invoiceNumber;
  final String date;
  final String partyName; // Customer or Supplier Name
  final String? customerId;
  final String? supplierId;
  final List<InvoiceItem> items;
  final InvoiceType type;
  final String? accountId;

  const Invoice({
    this.id,
    required this.invoiceNumber,
    required this.date,
    required this.partyName,
    this.customerId,
    this.supplierId,
    required this.items,
    required this.type,
    this.accountId,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'date': date,
        'partyName': partyName,
        'customerId': customerId,
        'supplierId': supplierId,
        'items': items.map((i) => i.toMap()).toList(),
        'type': type.index,
        'accountId': accountId,
      };

  factory Invoice.fromMap(Map<String, dynamic> map, {String? documentId}) => Invoice(
        id: documentId ?? map['id']?.toString(),
        invoiceNumber: map['invoiceNumber'] ?? '',
        date: map['date'] ?? '',
        partyName: map['partyName'] ?? '',
        customerId: map['customerId']?.toString(),
        supplierId: map['supplierId']?.toString(),
        items: (map['items'] as List? ?? [])
            .map((i) => InvoiceItem.fromMap(i as Map<String, dynamic>))
            .toList(),
        type: InvoiceType.values[map['type'] ?? 0],
        accountId: map['accountId']?.toString(),
      );

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        date,
        partyName,
        customerId,
        supplierId,
        items,
        type,
        accountId
      ];
}
