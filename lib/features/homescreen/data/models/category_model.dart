import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  final String slug;
  final String description;
  final int mealsCount;
  final int sortOrder;
  final String createdAt;

  const CategoryModel({
    required String id,
    required String name,
    required String
    iconUrl, // بنربط الـ iconUrl بـ image_url الموجودة في الـ JSON
    required this.slug,
    required this.description,
    required this.mealsCount,
    required this.sortOrder,
    required this.createdAt,
  }) : super(id: id, name: name, iconUrl: iconUrl);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['image_url'] ?? '',
      mealsCount: json['meals_count'] ?? 0,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image_url': iconUrl,
      'meals_count': mealsCount,
      'sort_order': sortOrder,
      'created_at': createdAt,
    };
  }
}
