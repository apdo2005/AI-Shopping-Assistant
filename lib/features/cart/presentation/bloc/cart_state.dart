import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_entity.dart';

sealed class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartEntity cart;
  final Set<int> pendingItemIds;
  final bool isClearing;
  const CartLoaded(
    this.cart, {
    this.pendingItemIds = const {},
    this.isClearing = false,
  });
  @override
  List<Object?> get props => [cart, pendingItemIds, isClearing];
}

class CartEmpty extends CartState {
  final bool isClearing;
  const CartEmpty({this.isClearing = false});
  @override
  List<Object?> get props => [isClearing];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}
