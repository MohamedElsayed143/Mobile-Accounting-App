class Invoice {
  int? id;
  String date;
  double totalAmount;
  int accountId;

  Invoice({this.id, required this.date, required this.totalAmount, required this.accountId});

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['ID'],
      date: map['date'],
      totalAmount: map['total amount']?.toDouble() ?? 0.0,
      accountId: map['account id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'date': date,
      'total amount': totalAmount,
      'account id': accountId,
    };
  }
}