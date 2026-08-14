import '../../domain/entities/cart_entity.dart';

class CartModel extends CartEntity {
  const CartModel({
    required super.id,
    required super.status,
    required super.items,
    required super.itemCount,
    required super.subtotal,
    required super.tax,
    required super.discount,
    required super.total,
    required super.isEmpty,
  });
  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    id: _int(json['id']),
    status: json['status']?.toString() ?? '',
    items: _list(
      json['items'],
    ).map((item) => CartItemModel.fromJson(_map(item))).toList(),
    itemCount: _int(json['item_count']),
    subtotal: _double(json['subtotal']),
    tax: _double(json['tax']),
    discount: _double(json['discount']),
    total: _double(json['total']),
    isEmpty: json['is_empty'] == true,
  );
}

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.meal,
    required super.quantity,
    required super.unitPrice,
    required super.discountAmount,
    required super.subtotal,
  });
  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: _int(json['id']),
    meal: CartMealModel.fromJson(_map(json['meal'])),
    quantity: _int(json['quantity']),
    unitPrice: _double(json['unit_price']),
    discountAmount: _double(json['discount_amount']),
    subtotal: _double(json['subtotal']),
  );
}

class CartMealModel extends CartMealEntity {
  const CartMealModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.brand,
    required super.categoryName,
    required super.size,
    required super.price,
    required super.discountPrice,
    required super.finalPrice,
    required super.stockQuantity,
    required super.isAvailable,
  });
  factory CartMealModel.fromJson(Map<String, dynamic> json) => CartMealModel(
    id: _int(json['id']),
    title: json['title']?.toString() ?? '',
    imageUrl: json['image_url']?.toString() ?? '',
    brand: _string(json['brand']),
    categoryName: _string(_map(json['category'])['name']),
    size: _string(json['size']),
    price: _double(json['price']),
    discountPrice: _nullableDouble(json['discount_price']),
    finalPrice: _double(json['final_price']),
    stockQuantity: _int(json['stock_quantity']),
    isAvailable: json['is_available'] == true && json['in_stock'] != false,
  );
}

Map<String, dynamic> _map(dynamic v) => v is Map<String, dynamic>
    ? v
    : v is Map
    ? Map<String, dynamic>.from(v)
    : {};
List<dynamic> _list(dynamic v) => v is List ? v : const [];
int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
double _double(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
double? _nullableDouble(dynamic v) {
  if (v == null || v.toString().trim().isEmpty) return null;
  return v is num ? v.toDouble() : double.tryParse('$v');
}
String? _string(dynamic v) {
  final s = v?.toString().trim();
  return s == null || s.isEmpty ? null : s;
}
