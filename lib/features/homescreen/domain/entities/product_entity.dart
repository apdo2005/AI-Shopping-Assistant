class ProductEntity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final double? discountPrice;
  final double finalPrice;
  final double rating;
  final int ratingCount;
  final bool hasOffer;
  final bool isFeatured;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.discountPrice,
    required this.finalPrice,
    required this.rating,
    required this.ratingCount,
    required this.hasOffer,
    required this.isFeatured,
  });
}
