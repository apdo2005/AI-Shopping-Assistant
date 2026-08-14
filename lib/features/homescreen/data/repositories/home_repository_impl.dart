import 'package:ai_shopping_assistant/features/homescreen/data/datasources/home_remote_data_source.dart';
import 'package:ai_shopping_assistant/features/homescreen/domain/entities/category_entity.dart';
import 'package:ai_shopping_assistant/features/homescreen/domain/entities/product_entity.dart';
import 'package:ai_shopping_assistant/features/homescreen/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);
  Future<Either<String, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, List<ProductEntity>>> getRecommendations() async {
    try {
      final products = await remoteDataSource.getRecommendations();
      return Right(products);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
