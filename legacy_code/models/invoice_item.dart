class InvoiceItem {
  int? id;
  int invoiceId;
  String itemName;
  int quantity;
  double price;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoice id'],
      itemName: map['item name'],
      quantity: map['quantity'],
      price: map['price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice id': invoiceId,
      'item name': itemName,
      'quantity': quantity,
      'price': price,
    };
  }
}