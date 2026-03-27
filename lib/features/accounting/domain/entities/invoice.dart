import 'package:equatable/equatable.dart';

enum InvoiceType { sale, purchase }

class InvoiceItem extends Equatable {
  final String description;
  final double quantity;
  final double price;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  @override
  List<Object?> get props => [description, quantity, price];
}

class Invoice extends Equatable {
  final String invoiceNumber;
  final String date;
  final String customerName;
  final List<InvoiceItem> items;
  final InvoiceType type;

  const Invoice({
    required this.invoiceNumber,
    required this.date,
    required this.customerName,
    required this.items,
    required this.type,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  @override
  List<Object?> get props => [invoiceNumber, date, customerName, items, type];
}
