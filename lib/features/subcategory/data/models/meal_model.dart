import '../../domain/entities/meal_entity.dart';

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.price,
    super.discountPrice,
    required super.finalPrice,
    required super.rating,
    required super.ratingCount,
    required super.hasOffer,
    required super.isFeatured,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final discountPrice = (json['discount_price'] as num?)?.toDouble();
    return MealModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: discountPrice,
      finalPrice:
          (json['final_price'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      // إذا في discount_price يبقى في عرض
      hasOffer: json['has_offer'] ?? discountPrice != null,
      isFeatured: json['is_featured'] ?? false,
    );
  }
}
