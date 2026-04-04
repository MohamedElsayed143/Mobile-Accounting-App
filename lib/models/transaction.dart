 class Transaction {
  final String id;
  final String date;
  final String description;
  final double debit;
  final double credit;
  final String customerName;

  Transaction({
    required this.id,
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
    required this.customerName,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      date: map['date'],
      description: map['description'],
      debit: map['debit'],
      credit: map['credit'],
      customerName: map['customerName'],
    );
  }
}