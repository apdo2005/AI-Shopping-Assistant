import 'package:ai_shopping_assistant/features/homescreen/domain/repositories/home_repository.dart';
import 'package:dartz/dartz.dart';

class GetHomeDataUsecase {
  final HomeRepository repository;

  GetHomeDataUsecase(this.repository);

  Future<Either<String, Map<String, dynamic>>> excute() async {
    try {
      final categoryResult = await repository.getCategories();
      final productResult = await repository.getRecommendations();

      return categoryResult.fold(
        (error) => Left(error),
        (categories) => productResult.fold(
          (error) => Left(error),
          (products) => Right({'categories': categories, 'products': products}),
        ),
      );
    } catch (e) {
      return Left('Failed to fetch home data');
    }
  }
}
