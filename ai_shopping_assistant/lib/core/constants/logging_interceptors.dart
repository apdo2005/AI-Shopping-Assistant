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
    print('❌ ERROR DETECTED');
    print('Status Code: ${err.response?.statusCode}');
    print('Error data: ${err.response?.data}');
    handler.next(err);
  }
}
