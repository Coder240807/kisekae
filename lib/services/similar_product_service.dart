import 'package:dio/dio.dart';
import 'package:kisekae/models/similar_product.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class SimilarProductsService extends BaseRepository {
  final Dio _dio;

  SimilarProductsService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<SimilarProduct>> getSimilar(
    int productId, {
    int limit = 10,
    bool sameCategory = false,
    CancelToken? cancelToken,
  }) {
    return execute(() async {
      final response = await _dio.get(
        '/products/$productId/similar/',
        queryParameters: {
          'limit': limit,
          if (sameCategory) 'same_category': true,
        },
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'];
      final list = data is List
          ? data
          : (data is Map ? (data['results'] as List<dynamic>? ?? []) : []);

      return list
          .whereType<Map>()
          .map((e) => SimilarProduct.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }
}
