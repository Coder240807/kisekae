import 'package:dio/dio.dart';

class ApiException implements Exception {
  final int? statusCode;
  final bool success;
  final String message;
  final String? code;
  final String? details;

  ApiException({
    this.statusCode,
    required this.success,
    required this.message,
    this.code,
    this.details,
  });

  factory ApiException.fromDioException(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      return ApiException(
        statusCode: e.response?.statusCode,
        success: responseData['success'] as bool? ?? false,
        message: responseData['message'] as String? ?? 'An error occurred',
        code: responseData['error']?['code'] as String?,
        details: responseData['error']?['details'] as String?,
      );
    }
    return ApiException(
      statusCode: e.response?.statusCode,
      success: false,
      message: e.message ?? 'Network connection error',
    );
  }

  @override
  String toString() => '[$statusCode - $code] $message: $details';
}
