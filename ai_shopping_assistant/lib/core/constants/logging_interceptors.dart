import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('╔════════════════════════════════════════════════════════════');
    log('║ 🚀 REQUEST');
    log('║ ────────────────────────────────────────────────────────────');
    log('║ Method: ${options.method}');
    log('║ URL: ${options.uri}');
    log('║ Headers: ${options.headers}');

    if (options.queryParameters.isNotEmpty) {
      log('║ Query Parameters: ${options.queryParameters}');
    }

    if (options.data != null) {
      log('║ Body: ${options.data}');
    }

    log('╚════════════════════════════════════════════════════════════');

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    log('╔════════════════════════════════════════════════════════════');
    log('║ ✅ RESPONSE');
    log('║ ────────────────────────────────────────────────────────────');
    log('║ Status Code: ${response.statusCode}');
    log('║ URL: ${response.requestOptions.uri}');

    final responseData = response.data.toString();
    if (responseData.length > 500) {
      log('║ data: ${responseData.substring(0, 500)}... (truncated)');
    } else {
      log('║ data: $responseData');
    }

    log('╚════════════════════════════════════════════════════════════');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('╔════════════════════════════════════════');
    log('❌ DIO ERROR');
    log('TYPE: ${err.type}');
    log('MESSAGE: ${err.message}');
    log('URL: ${err.requestOptions.uri}');
    log('STATUS: ${err.response?.statusCode}');
    log('DATA: ${err.response?.data}');
    log('╚════════════════════════════════════════');

    handler.next(err);
  }
}
