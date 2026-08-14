class CartEntity {
  final int id;
  final String status;
  final List<CartItemEntity> items;
  final int itemCount;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final bool isEmpty;

  const CartEntity({
    required this.id,
    required this.status,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.isEmpty,
  });
}

class CartItemEntity {
  final int id;
  final CartMealEntity meal;
  final int quantity;
  final double unitPrice;
  final double discountAmount;
  final double subtotal;

  const CartItemEntity({
    required this.id,
    required this.meal,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.subtotal,
  });
}

class CartMealEntity {
  final int id;
  final String title;
  final String imageUrl;
  final String? brand;
  final String? categoryName;
  final String? size;
  final double price;
  final double? discountPrice;
  final double finalPrice;
  final int stockQuantity;
  final bool isAvailable;

  const CartMealEntity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.brand,
    required this.categoryName,
    required this.size,
    required this.price,
    required this.discountPrice,
    required this.finalPrice,
    required this.stockQuantity,
    required this.isAvailable,
  });
}
