import 'package:dio/dio.dart';
import 'package:ai_shopping_assistant/core/constants/api_constant.dart';
import 'package:ai_shopping_assistant/core/error/exceptions.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addItem(int mealId, int quantity);
  Future<CartModel> removeItem(int itemId);
  Future<CartModel> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;
  CartRemoteDataSourceImpl(this.dio);
  @override
  Future<CartModel> getCart() => _request(() => dio.get(ApiConstant.getCart));
  @override
  Future<CartModel> addItem(int mealId, int quantity) => _request(
    () => dio.post(
      ApiConstant.addToCart,
      data: {'meal_id': mealId, 'quantity': quantity},
    ),
  );
  @override
  Future<CartModel> removeItem(int itemId) =>
      _request(() => dio.delete(ApiConstant.removeCartItem(itemId)));
  @override
  Future<CartModel> clearCart() =>
      _request(() => dio.delete(ApiConstant.clearCart));
  Future<CartModel> _request(Future<Response> Function() call) async {
    try {
      final response = await call();
      final body = response.data;
      if ((response.statusCode ?? 500) < 200 ||
          (response.statusCode ?? 500) >= 300 ||
          body is! Map ||
          body['success'] != true)
        throw _error(response);
      final data = body['data'];
      if (data is! Map) throw ServerException('Cart data is unavailable.');
      return CartModel.fromJson(Map<String, dynamic>.from(data));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw NetworkException(
        _message(e.response?.data) ?? 'Check your connection and try again.',
      );
    } catch (_) {
      throw ServerException('Unable to update your cart. Please try again.');
    }
  }

  AppException _error(Response response) {
    final message =
        _message(response.data) ??
        'Unable to update your cart. Please try again.';
    if (response.statusCode == 401)
      return AuthException('Your session has expired. Please sign in again.');
    if (response.statusCode == 422) return ValidationException(message);
    return ServerException(message);
  }

  String? _message(dynamic body) => body is Map && body['message'] != null
      ? body['message'].toString()
      : null;
}
