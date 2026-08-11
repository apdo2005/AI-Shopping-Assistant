import '../../domain/entities/subcategory_entity.dart';

class SubcategoryModel extends SubcategoryEntity {
  const SubcategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.description,
    required super.mealsCount,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? '',
      description: json['description'] ?? '',
      mealsCount: (json['meals_count'] as num?)?.toInt() ?? 0,
    );
  }
}

/// يبني قائمة CategoryGroupEntity من الـ flat subcategories list
List<CategoryGroupEntity> groupSubcategoriesByCategory(
  List<Map<String, dynamic>> jsonList,
) {
  // Map<categoryId, CategoryGroup>
  final Map<String, CategoryGroupEntity> grouped = {};

  for (final json in jsonList) {
    final catJson = json['category'] as Map<String, dynamic>?;
    if (catJson == null) continue;

    final catId = catJson['id']?.toString() ?? '';
    final catName = catJson['name']?.toString() ?? '';
    final subcategory = SubcategoryModel.fromJson(json);

    if (grouped.containsKey(catId)) {
      // أضف الـ subcategory للـ group الموجودة
      final existing = grouped[catId]!;
      grouped[catId] = CategoryGroupEntity(
        categoryId: existing.categoryId,
        categoryName: existing.categoryName,
        subcategories: [...existing.subcategories, subcategory],
      );
    } else {
      grouped[catId] = CategoryGroupEntity(
        categoryId: catId,
        categoryName: catName,
        subcategories: [subcategory],
      );
    }
  }

  // رتّبهم بـ categoryId
  final result = grouped.values.toList()
    ..sort((a, b) => a.categoryId.compareTo(b.categoryId));

  return result;
}
