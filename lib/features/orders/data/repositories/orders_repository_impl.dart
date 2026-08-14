import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource source;
  OrdersRepositoryImpl(this.source);
  @override
  Future<OrderEntity> createOrder(CreateOrderRequest request) =>
      source.create(request);
  @override
  Future<OrderEntity?> getOrderDetails(int id) => source.details(id);
  @override
  Future<List<OrderEntity>> getOrders() => source.getOrders();
  @override
  Future<OrderEntity?> trackActiveOrder() => source.track();
}
