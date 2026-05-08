import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String? id;
  final String code;
  final String name;
  final double buyPrice;
  final double sellPrice;
  final double quantity;
  final double discount; // نسبة الخصم

  const Product({
    this.id,
    required this.code,
    required this.name,
    this.buyPrice = 0.0,
    this.sellPrice = 0.0,
    this.quantity = 0.0,
    this.discount = 0.0,
  });

  Product copyWith({
    String? id,
    String? code,
    String? name,
    double? buyPrice,
    double? sellPrice,
    double? quantity,
    double? discount,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'quantity': quantity,
        'discount': discount,
      };

  factory Product.fromMap(Map<String, dynamic> map, {String? documentId}) => Product(
        id: documentId ?? map['id']?.toString(),
        code: map['code'] ?? '',
        name: map['name'] ?? '',
        buyPrice: (map['buyPrice'] as num?)?.toDouble() ?? 0.0,
        sellPrice: (map['sellPrice'] as num?)?.toDouble() ?? 0.0,
        quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
        discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [id, code, name, buyPrice, sellPrice, quantity, discount];
}
