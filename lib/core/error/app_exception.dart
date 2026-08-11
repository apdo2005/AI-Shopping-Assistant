import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final AppExceptionType type;

  const AppException({
    required this.message,
    this.statusCode,
    this.type = AppExceptionType.unknown,
  });

  @override
  String toString() => message;
}

enum AppExceptionType {
  noInternet,
  timeout,
  serverError,
  unauthorized,
  notFound,
  badRequest,
  cancelled,
  unknown,
}

AppException handleException(Object error) {
  if (error is AppException) return error;

  if (error is DioException) {
    return _fromDio(error);
  }

  return AppException(
    message: error.toString().replaceFirst('Exception: ', ''),
    type: AppExceptionType.unknown,
  );
}

AppException _fromDio(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const AppException(
        message: 'Connection timed out. Please check your internet and try again.',
        type: AppExceptionType.timeout,
      );

    case DioExceptionType.connectionError:
      return const AppException(
        message: 'No internet connection. Please check your network.',
        type: AppExceptionType.noInternet,
      );

    case DioExceptionType.cancel:
      return const AppException(
        message: 'Request was cancelled.',
        type: AppExceptionType.cancelled,
      );

    case DioExceptionType.badResponse:
      return _fromStatusCode(e.response?.statusCode, e.response?.data);

    default:
      return AppException(
        message: e.message ?? 'An unexpected error occurred.',
        type: AppExceptionType.unknown,
      );
  }
}

AppException _fromStatusCode(int? statusCode, dynamic data) {

  String? serverMessage;
  if (data is Map) {
    serverMessage = data['message']?.toString() ??
        data['error']?.toString() ??
        data['msg']?.toString();
  }

  switch (statusCode) {
    case 400:
      return AppException(
        message: serverMessage ?? 'Bad request. Please check your input.',
        statusCode: 400,
        type: AppExceptionType.badRequest,
      );
    case 401:
      return AppException(
        message: serverMessage ?? 'Session expired. Please log in again.',
        statusCode: 401,
        type: AppExceptionType.unauthorized,
      );
    case 403:
      return AppException(
        message: serverMessage ?? 'You don\'t have permission to do this.',
        statusCode: 403,
        type: AppExceptionType.unauthorized,
      );
    case 404:
      return AppException(
        message: serverMessage ?? 'The requested resource was not found.',
        statusCode: 404,
        type: AppExceptionType.notFound,
      );
    case 409:
      return AppException(
        message: serverMessage ?? 'Conflict: this action cannot be completed.',
        statusCode: 409,
        type: AppExceptionType.badRequest,
      );
    case 422:
      return AppException(
        message: serverMessage ?? 'Validation failed. Please check your input.',
        statusCode: 422,
        type: AppExceptionType.badRequest,
      );
    case 429:
      return AppException(
        message: serverMessage ?? 'Too many requests. Please slow down.',
        statusCode: 429,
        type: AppExceptionType.serverError,
      );
    case 500:
    case 502:
    case 503:
      return AppException(
        message: serverMessage ?? 'Server error. Please try again later.',
        statusCode: statusCode,
        type: AppExceptionType.serverError,
      );
    default:
      return AppException(
        message: serverMessage ?? 'Something went wrong (code: $statusCode).',
        statusCode: statusCode,
        type: AppExceptionType.unknown,
      );
  }
}
