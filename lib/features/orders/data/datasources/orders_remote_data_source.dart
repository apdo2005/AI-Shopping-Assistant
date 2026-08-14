import 'package:dio/dio.dart';
import 'package:ai_shopping_assistant/core/constants/api_constant.dart';
import 'package:ai_shopping_assistant/core/error/app_exception.dart';
import '../models/order_model.dart';
import '../../domain/entities/order_entity.dart';

class OrdersRemoteDataSource {
  final Dio dio;
  OrdersRemoteDataSource(this.dio);
  Future<List<OrderModel>> getOrders() async {
    final data = await _request(() => dio.get(ApiConstant.getOrders));
    return _list(
      data['data'],
    ).map((e) => OrderModel.fromJson(_map(e))).toList();
  }

  Future<OrderModel?> details(int id) async {
    final data = await _request(
      () => dio.get(ApiConstant.orderDetails(id)),
      allowNotFound: true,
    );
    final raw = data['data'];
    return raw is Map && raw['id'] != null
        ? OrderModel.fromJson(_map(raw))
        : null;
  }

  Future<OrderModel?> track() async {
    final data = await _request(
      () => dio.get(ApiConstant.trackOrder),
      allowNoActive: true,
    );
    final raw = data['data'];
    return raw is Map ? OrderModel.fromJson(_map(raw)) : null;
  }

  Future<OrderModel> create(CreateOrderRequest r) async {
    final fields = <String, dynamic>{
      'payment_method': r.paymentMethod,
      'delivery_type': r.deliveryType,
      'amount': r.amount.toStringAsFixed(2),
    };
    if (r.addressId != null) fields['address_id'] = r.addressId;
    if (r.paymentMethodId != null)
      fields['payment_method_id'] = r.paymentMethodId;
    if (r.specialNoteId != null) fields['special_note_id'] = r.specialNoteId;
    if (r.notes?.trim().isNotEmpty == true) fields['notes'] = r.notes;
    if (r.scheduleDelivery?.isNotEmpty == true)
      fields['schedule_delivery'] = r.scheduleDelivery;
    if (r.deliverySpeed?.isNotEmpty == true)
      fields['delivery_speed'] = r.deliverySpeed;
    if (r.estimatedDeliveryTime?.isNotEmpty == true)
      fields['estimated_delivery_time'] = r.estimatedDeliveryTime;
    final data = await _request(
      () => dio.post(ApiConstant.getOrders, data: FormData.fromMap(fields)),
    );
    final raw = data['data'];
    return raw is Map ? OrderModel.fromJson(_map(raw)) : const OrderModel();
  }

  Future<Map<String, dynamic>> _request(
    Future<Response> Function() call, {
    bool allowNoActive = false,
    bool allowNotFound = false,
  }) async {
    try {
      final response = await call();
      final body = _map(response.data);
      final code = response.statusCode ?? 0;
      if (allowNoActive &&
          body['success'] == false &&
          _string(body['message']).toLowerCase().contains('no active order'))
        return body;
      if (allowNotFound && code == 404) return body;
      if (code < 200 || code >= 300 || body['success'] != true)
        throw _error(code, body);
      return body;
    } on DioException catch (e) {
      throw handleException(e);
    }
  }

  AppException _error(int code, Map<String, dynamic> b) {
    final errors = b['errors'];
    String message = _string(
      b['message'],
      'Unable to complete the order request.',
    );
    if (errors is Map && errors.values.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) message = first.first.toString();
    }
    return AppException(
      message: message,
      statusCode: code,
      type: code == 401 || code == 403
          ? AppExceptionType.unauthorized
          : code == 404
          ? AppExceptionType.notFound
          : code == 422
          ? AppExceptionType.badRequest
          : AppExceptionType.serverError,
    );
  }
}

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : {};
List<dynamic> _list(dynamic v) => v is List ? v : [];
String _string(dynamic v, [String f = '']) => v?.toString() ?? f;
