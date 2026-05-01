class Account {
  int? id;
  String name;
  int type; // غيرناها int
  double balance;
  String code;

  Account({
    this.id,
    required this.name,
    required this.code,
    required this.type,
    this.balance = 0.0,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      type: map['type'],
      balance: (map['balance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type,
      'balance': balance,
    };
  }
}