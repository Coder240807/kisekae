import 'package:dio/dio.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/dashboard_model.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class Analytics extends BaseRepository {
  final Dio _dio;

  Analytics([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<DashboardMetrics> getStoreDashboardMetrics(
    int storeId, {
    String? fromDate,
    String? toDate,
  }) {
    return execute(() async {
      final Map<String, dynamic> queryParams = {};
      if (fromDate != null) queryParams['from_date'] = fromDate;
      if (toDate != null) queryParams['to_date'] = toDate;

      final response = await _dio.get(
        '/stores/$storeId/analytics/dashboard/',
        queryParameters: queryParams,
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final dynamic rawData = responseData['data'];

        if (rawData is String) {
          return DashboardMetrics.fromRawJson(rawData);
        } else if (rawData is Map<String, dynamic>) {
          return DashboardMetrics.fromJson(rawData);
        }
      }

      throw ApiException(
        statusCode: response.statusCode,
        success: responseData is Map<String, dynamic>
            ? (responseData['success'] as bool? ?? false)
            : false,
        message: responseData is Map<String, dynamic>
            ? (responseData['message'] as String? ??
                  'Failed to parse analytics metrics')
            : 'Invalid response format',
      );
    });
  }
}
