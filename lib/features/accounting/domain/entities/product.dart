import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
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
    int? id,
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

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'code': code,
        'name': name,
        'buy_price': buyPrice,
        'sell_price': sellPrice,
        'quantity': quantity,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        code: map['code'] ?? '',
        name: map['name'] ?? '',
        buyPrice: (map['buy_price'] as num?)?.toDouble() ?? 0.0,
        sellPrice: (map['sell_price'] as num?)?.toDouble() ?? 0.0,
        quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [id, code, name, buyPrice, sellPrice, quantity];
}
