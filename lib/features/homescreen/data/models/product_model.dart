import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  final String slug;

  const ProductModel({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required double price,
    double? discountPrice,
    required double finalPrice,
    required double rating,
    required int ratingCount,
    required bool hasOffer,
    required bool isFeatured,
    required this.slug,
  }) : super(
         id: id,
         title: title,
         description: description,
         imageUrl: imageUrl,
         price: price,
         discountPrice: discountPrice,
         finalPrice: finalPrice,
         rating: rating,
         ratingCount: ratingCount,
         hasOffer: hasOffer,
         isFeatured: isFeatured,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] ?? 0,
      hasOffer: json['has_offer'] ?? false,
      isFeatured: json['is_featured'] ?? false,
    );
  }
}
