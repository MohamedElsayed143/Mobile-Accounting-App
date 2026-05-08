import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final double balance;

  const Customer({
    this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.balance = 0.0,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? balance,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'balance': balance,
      };

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// للتوافق مع الكود القديم
  Map<String, dynamic> toMap() => toFirestore();

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
        id: map['id']?.toString(),
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'] ?? '',
        address: map['address'] ?? '',
        balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [id, name, phone, email, address, balance];
}
