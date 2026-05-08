import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum AccountType { asset, liability, equity, income, expense }

class Account extends Equatable {
  final String? id;
  final String code;
  final String name;
  final AccountType type;
  final double balance;

  const Account({
    this.id,
    required this.code,
    required this.name,
    required this.type,
    this.balance = 0.0,
  });

  Account copyWith({
    String? id,
    String? code,
    String? name,
    AccountType? type,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'type': type.index,
      'balance': balance,
    };
  }

  factory Account.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Account(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      type: AccountType.values[data['type'] ?? 0],
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// للتوافق مع الكود القديم
  Map<String, dynamic> toMap() => toFirestore();

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id']?.toString(),
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      type: AccountType.values[map['type'] ?? 0],
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [id, code, name, type, balance];
}
