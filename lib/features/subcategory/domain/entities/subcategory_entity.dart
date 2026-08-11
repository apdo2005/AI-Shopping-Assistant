class SubcategoryEntity {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int mealsCount;

  const SubcategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.mealsCount,
  });
}

/// يمثل category كاملة مع الـ subcategories بتاعتها
class CategoryGroupEntity {
  final String categoryId;
  final String categoryName;
  final List<SubcategoryEntity> subcategories;

  const CategoryGroupEntity({
    required this.categoryId,
    required this.categoryName,
    required this.subcategories,
  });
}
