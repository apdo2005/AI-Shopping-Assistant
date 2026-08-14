import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity?> getOrderDetails(int id);
  Future<OrderEntity?> trackActiveOrder();
  Future<OrderEntity> createOrder(CreateOrderRequest request);
}
