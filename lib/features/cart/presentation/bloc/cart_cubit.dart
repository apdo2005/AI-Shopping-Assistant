import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository repository;
  CartCubit(this.repository) : super(CartInitial());
  Future<void> load() async {
    emit(CartLoading());
    final result = await repository.getCart();
    result.fold((e) => emit(CartError(e)), _emitCart);
  }

  Future<bool> addItem(int mealId, {int quantity = 1}) async {
    final result = await repository.addItem(mealId, quantity);
    return result.fold((e) => false, (cart) {
      _emitCart(cart);
      return true;
    });
  }

  Future<String?> removeItem(int itemId) async {
    final current = state;
    if (current is CartLoaded) {
      emit(
        CartLoaded(
          current.cart,
          pendingItemIds: {...current.pendingItemIds, itemId},
        ),
      );
    }
    final result = await repository.removeItem(itemId);
    return result.fold(
      (e) {
        if (current is CartLoaded) emit(current);
        return e;
      },
      (cart) {
        _emitCart(cart);
        return null;
      },
    );
  }

  Future<String?> clear() async {
    final current = state;
    if (current is CartLoaded) emit(CartLoaded(current.cart, isClearing: true));
    final result = await repository.clearCart();
    return result.fold(
      (e) {
        if (current is CartLoaded) emit(current);
        return e;
      },
      (cart) {
        _emitCart(cart);
        return null;
      },
    );
  }

  void _emitCart(CartEntity cart) =>
      cart.isEmpty ? emit(const CartEmpty()) : emit(CartLoaded(cart));
}
