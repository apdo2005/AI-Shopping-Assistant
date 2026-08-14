import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';

sealed class OrdersState {
  const OrdersState();
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  const OrdersLoaded(this.orders);
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
}

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repository;
  OrdersCubit(this.repository) : super(const OrdersInitial());
  Future<void> load() async {
    emit(const OrdersLoading());
    try {
      emit(OrdersLoaded(await repository.getOrders()));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<OrderEntity?> track() => repository.trackActiveOrder();
  Future<OrderEntity?> details(int id) => repository.getOrderDetails(id);
  Future<OrderEntity> create(CreateOrderRequest r) => repository.createOrder(r);
}
