class OrderEntity {
  final int? id;
  final String number, status, statusDescription, deliveryType, paymentMethod;
  final int statusPosition;
  final List<OrderItemEntity> items;
  final Map<String, dynamic>? address;
  final double subtotal, tax, discount, shippingFee, total;
  final String? createdAt,
      placedAt,
      processingAt,
      shippingAt,
      outForDeliveryAt,
      deliveredAt,
      estimatedDeliveryTime,
      deliverySpeed,
      scheduleDelivery,
      notes,
      specialNote;

  const OrderEntity({
    this.id,
    this.number = '',
    this.status = 'unknown',
    this.statusDescription = '',
    this.deliveryType = '',
    this.paymentMethod = '',
    this.statusPosition = 0,
    this.items = const [],
    this.address,
    this.subtotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.shippingFee = 0,
    this.total = 0,
    this.createdAt,
    this.placedAt,
    this.processingAt,
    this.shippingAt,
    this.outForDeliveryAt,
    this.deliveredAt,
    this.estimatedDeliveryTime,
    this.deliverySpeed,
    this.scheduleDelivery,
    this.notes,
    this.specialNote,
  });
  int get itemCount => items.length;
}

class OrderItemEntity {
  final String name, imageUrl, brand, categoryName, size;
  final int quantity;
  final double unitPrice, subtotal;
  const OrderItemEntity({
    this.name = '',
    this.imageUrl = '',
    this.brand = '',
    this.categoryName = '',
    this.size = '',
    this.quantity = 0,
    this.unitPrice = 0,
    this.subtotal = 0,
  });
}

class CreateOrderRequest {
  final double amount;
  final String paymentMethod, deliveryType;
  final int? addressId, paymentMethodId, specialNoteId;
  final String? notes, scheduleDelivery, deliverySpeed, estimatedDeliveryTime;
  const CreateOrderRequest({
    required this.amount,
    required this.paymentMethod,
    required this.deliveryType,
    this.addressId,
    this.paymentMethodId,
    this.specialNoteId,
    this.notes,
    this.scheduleDelivery,
    this.deliverySpeed,
    this.estimatedDeliveryTime,
  });
}
