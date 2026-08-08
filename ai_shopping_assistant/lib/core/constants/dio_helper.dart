import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../error/app_exception.dart';
import 'auth_interceptor.dart';
import 'logging_interceptors.dart';

class DioHelper {
  DioHelper._();
  static late Dio _dio;
  static void init({
    required String baseUrl,
    Duration timeout = const Duration(seconds: 30),
    bool enableLogger = true,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status >= 100 && status < 600;
        },
      ),
    );
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };

        return client;
      },
    );

    _addInterceptors(enableLogger);
  }

  static Dio get dio => _dio;

  static void _addInterceptors(bool enableLogger) {
    _dio.interceptors.add(AuthInterceptor());

    if (enableLogger) {
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  static Future<Response> get({
    required String path,
    Map<String, dynamic>? query,
    bool withAuth = false,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: query,
        options: Options(
          extra: {'withAuth': withAuth},
        ),
      );
    } catch (e) {
      throw handleException(e);
    }
  }


  static Future<Response> post({
    required String path,
    dynamic data,
    Map<String, dynamic>? query,
    bool withAuth = false,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          extra: {'withAuth': withAuth},
        ),
      );
    } on DioException catch (e) {
      print('========== DIO POST ERROR ==========');
      print('TYPE: ${e.type}');
      print('MESSAGE: ${e.message}');
      print('URL: ${e.requestOptions.uri}');
      print('RESPONSE: ${e.response}');
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('====================================');

      rethrow;
    }
  }


  static Future<Response> put({
    required String path,
    dynamic data,
    Map<String, dynamic>? query,
    bool withAuth = false,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          extra: {'withAuth': withAuth},
        ),
      );
    } on DioException catch (e) {
      print('========== DIO PUT ERROR ==========');
      print('TYPE: ${e.type}');
      print('MESSAGE: ${e.message}');
      print('URL: ${e.requestOptions.uri}');
      print('RESPONSE: ${e.response}');
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('===================================');

      rethrow;
    }
  }

  static Future<Response> delete({
    required String path,
    dynamic data,
    Map<String, dynamic>? query,
    bool withAuth = false,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          extra: {'withAuth': withAuth},
        ),
      );
    } on DioException catch (e) {
      print('========== DIO DELETE ERROR ==========');
      print('TYPE: ${e.type}');
      print('MESSAGE: ${e.message}');
      print('URL: ${e.requestOptions.uri}');
      print('RESPONSE: ${e.response}');
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('=====================================');

      rethrow;
    }
  }

  static Future<Response> postFormData({
    required String path,
    required FormData formData,
    Map<String, dynamic>? query,
    bool withAuth = false,
  }) async {
    try {
      return await _dio.post(
        path,
        data: formData,
        queryParameters: query,
        options: Options(
          extra: {'withAuth': withAuth},
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      print('========== DIO FORM DATA ERROR ==========');
      print('TYPE: ${e.type}');
      print('MESSAGE: ${e.message}');
      print('URL: ${e.requestOptions.uri}');
      print('RESPONSE: ${e.response}');
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('========================================');

      rethrow;
    }
  }
}