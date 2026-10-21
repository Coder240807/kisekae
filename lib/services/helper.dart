import 'package:dio/dio.dart';
import 'package:kisekae/models/api_exception.dart';

abstract class BaseRepository {
  Future<T> execute<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      print('RESPONSE BODY: ${e.response?.data}');
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(
        statusCode: e.response?.statusCode,
        success: false,
        message: e.message ?? 'Request failed',
      );
    }
  }
}
