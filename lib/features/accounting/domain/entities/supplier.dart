import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final double balance;

  const Supplier({
    this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.balance = 0.0,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? balance,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'balance': balance,
      };

  factory Supplier.fromMap(Map<String, dynamic> map, {String? documentId}) => Supplier(
        id: documentId ?? map['id']?.toString(),
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'] ?? '',
        address: map['address'] ?? '',
        balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [id, name, phone, email, address, balance];
}
