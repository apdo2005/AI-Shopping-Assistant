import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    super.id,
    super.number,
    super.status,
    super.statusDescription,
    super.deliveryType,
    super.paymentMethod,
    super.statusPosition,
    super.items,
    super.address,
    super.subtotal,
    super.tax,
    super.discount,
    super.shippingFee,
    super.total,
    super.createdAt,
    super.placedAt,
    super.processingAt,
    super.shippingAt,
    super.outForDeliveryAt,
    super.deliveredAt,
    super.estimatedDeliveryTime,
    super.deliverySpeed,
    super.scheduleDelivery,
    super.notes,
    super.specialNote,
  });
  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: _int(json['id']),
    number: _string(json['order_number']),
    status: _string(json['status'], 'unknown'),
    statusDescription: _string(json['status_description']),
    deliveryType: _string(json['delivery_type']),
    paymentMethod: _string(json['payment_method']),
    statusPosition: _int(json['status_position']) ?? 0,
    items: _list(
      json['items'],
    ).map((e) => OrderItemModel.fromJson(_map(e))).toList(),
    address: json['address'] is Map ? _map(json['address']) : null,
    subtotal: _double(json['subtotal']),
    tax: _double(json['tax']),
    discount: _double(json['discount']),
    shippingFee: _double(json['shipping_fee']),
    total: _double(json['total'] ?? json['amount']),
    createdAt: _nullable(json['created_at']),
    placedAt: _nullable(json['placed_at']),
    processingAt: _nullable(json['processing_at']),
    shippingAt: _nullable(json['shipping_at']),
    outForDeliveryAt: _nullable(json['out_for_delivery_at']),
    deliveredAt: _nullable(json['delivered_at']),
    estimatedDeliveryTime: _nullable(json['estimated_delivery_time']),
    deliverySpeed: _nullable(json['delivery_speed']),
    scheduleDelivery: _nullable(json['schedule_delivery']),
    notes: _notes(json['notes']),
    specialNote: _nullable(json['special_note']),
  );
}

class OrderItemModel extends OrderItemEntity {
  OrderItemModel.fromJson(Map<String, dynamic> j)
    : super(
        name: _string(
          j['name'] ??
              j['product_name'] ??
              j['meal_name'] ??
              j['title'] ??
              _product(j)['title'],
        ),
        imageUrl: _string(
          j['image_url'] ??
              j['image'] ??
              _product(j)['image_url'] ??
              _product(j)['image'],
        ),
        brand: _string(_product(j)['brand']),
        categoryName: _string(
          _product(j)['category_name'] ?? _map(_product(j)['category'])['name'],
        ),
        size: _string(_product(j)['size']),
        quantity: _int(j['quantity']) ?? 0,
        unitPrice: _double(
          j['unit_price'] ??
              j['price'] ??
              _product(j)['final_price'] ??
              _product(j)['discount_price'] ??
              _product(j)['price'],
        ),
        subtotal: j['subtotal'] == null
            ? (_int(j['quantity']) ?? 0) *
                  _double(
                    j['unit_price'] ??
                        j['price'] ??
                        _product(j)['final_price'] ??
                        _product(j)['discount_price'] ??
                        _product(j)['price'],
                  )
            : _double(j['subtotal']),
      );
}

Map<String, dynamic> _product(Map<String, dynamic> item) {
  final meal = _map(item['meal']);
  return meal.isNotEmpty ? meal : _map(item['product']);
}

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : {};
List<dynamic> _list(dynamic v) => v is List ? v : [];
String _string(dynamic v, [String fallback = '']) => v?.toString() ?? fallback;
String? _nullable(dynamic v) =>
    v == null || v.toString().isEmpty ? '' : v.toString();
int? _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');
double _double(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
String? _notes(dynamic v) => v is List
    ? v.whereType<Object>().map((e) => e.toString()).join('\n')
    : _nullable(v);
