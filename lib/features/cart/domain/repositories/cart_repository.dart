import 'package:dartz/dartz.dart';
import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<Either<String, CartEntity>> getCart();
  Future<Either<String, CartEntity>> addItem(int mealId, int quantity);
  Future<Either<String, CartEntity>> removeItem(int itemId);
  Future<Either<String, CartEntity>> clearCart();
}
