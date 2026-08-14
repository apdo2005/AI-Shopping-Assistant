import 'package:dartz/dartz.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class HomeRepository {
  Future<Either<String, List<CategoryEntity>>> getCategories();
  Future<Either<String, List<ProductEntity>>>
  getRecommendations(); // Personalized / Today's deals
}
