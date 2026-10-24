import 'package:dio/dio.dart';
import 'package:kisekae/models/history.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class SearchService extends BaseRepository {
  final Dio _dio;

  SearchService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<SearchHistoryItem>> getSearchHistory({
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/products/search/history/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final list = body['data'] as List<dynamic>? ?? [];

      return list
          .map(
            (item) => SearchHistoryItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    });
  }

  Future<String> deleteSearchHistoryItem(
    int historyId, {
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.delete(
        '/products/search/history/$historyId/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      return body['message'] as String? ?? 'Search history entry deleted';
    });
  }

  Future<String> clearSearchHistory({CancelToken? cancelToken}) async {
    return execute(() async {
      final response = await _dio.delete(
        '/products/search/history/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      return body['message'] as String? ??
          'Search history cleared successfully';
    });
  }
}
