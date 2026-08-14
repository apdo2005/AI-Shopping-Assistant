import 'package:dartz/dartz.dart';
import 'package:ai_shopping_assistant/core/error/app_exception.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource source;
  CartRepositoryImpl(this.source);
  Future<Either<String, CartEntity>> _run(
    Future<CartEntity> Function() call,
  ) async {
    try {
      return Right(await call());
    } on AppException catch (e) {
      return Left(e.message);
    } catch (_) {
      return const Left('Unable to update your cart. Please try again.');
    }
  }

  @override
  Future<Either<String, CartEntity>> getCart() => _run(source.getCart);
  @override
  Future<Either<String, CartEntity>> addItem(int mealId, int quantity) =>
      _run(() => source.addItem(mealId, quantity));
  @override
  Future<Either<String, CartEntity>> removeItem(int itemId) =>
      _run(() => source.removeItem(itemId));
  @override
  Future<Either<String, CartEntity>> clearCart() => _run(source.clearCart);
}
