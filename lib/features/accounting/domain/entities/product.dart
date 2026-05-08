import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String? id;
  final String code;
  final String name;
  final double buyPrice;
  final double sellPrice;
  final double quantity;

  const Product({
    this.id,
    required this.code,
    required this.name,
    this.buyPrice = 0.0,
    this.sellPrice = 0.0,
    this.quantity = 0.0,
  });

  Product copyWith({
    String? id,
    String? code,
    String? name,
    double? buyPrice,
    double? sellPrice,
    double? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'code': code,
        'name': name,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'quantity': quantity,
      };

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      buyPrice: (data['buyPrice'] as num?)?.toDouble() ?? 0.0,
      sellPrice: (data['sellPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// للتوافق مع الكود القديم
  Map<String, dynamic> toMap() => toFirestore();

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id']?.toString(),
        code: map['code'] ?? '',
        name: map['name'] ?? '',
        buyPrice: (map['buyPrice'] as num?)?.toDouble() ??
            (map['buy_price'] as num?)?.toDouble() ?? 0.0,
        sellPrice: (map['sellPrice'] as num?)?.toDouble() ??
            (map['sell_price'] as num?)?.toDouble() ?? 0.0,
        quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [id, code, name, buyPrice, sellPrice, quantity];
}
