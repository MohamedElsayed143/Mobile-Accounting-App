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

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  @override
  List<Object?> get props =>
      [invoiceNumber, date, partyName, customerId, supplierId, items, type, accountId];
}
