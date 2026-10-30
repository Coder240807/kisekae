import 'package:dio/dio.dart';
import 'package:kisekae/models/tryon_combo_model.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class TryOnService extends BaseRepository {
  final Dio _dio;

  TryOnService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<TryOnCombo>> getUserCombos({CancelToken? cancelToken}) async {
    return execute(() async {
      final response = await _dio.get(
        '/profile/combos/',
        cancelToken: cancelToken,
      );

      if (response.data == null || response.data is! Map) {
        return [];
      }

      final body = Map<String, dynamic>.from(response.data as Map);
      final rawData = body['data'];

      if (rawData is List) {
        return rawData
            .whereType<Map>()
            .map((item) => TryOnCombo.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    });
  }

  Future<TryOnCombo> createCombo({
    required String name,
    required List<int> productIds,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/profile/combos/',
        data: {'name': name.trim(), 'product_ids': productIds},
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return TryOnCombo.fromJson(data);
    });
  }

  Future<TryOnCombo> getComboDetails({
    required int comboId,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/profile/combos/$comboId/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return TryOnCombo.fromJson(data);
    });
  }

  Future<TryOnCombo> updateCombo({
    required int comboId,
    String? name,
    List<int>? productIds,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final payload = <String, dynamic>{
        if (name != null) 'name': name.trim(),
        if (productIds != null) 'product_ids': productIds,
      };

      final response = await _dio.patch(
        '/profile/combos/$comboId/',
        data: payload,
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return TryOnCombo.fromJson(data);
    });
  }

  Future<bool> deleteCombo({
    required int comboId,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.delete(
        '/profile/combos/$comboId/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      return body['success'] as bool? ?? true;
    });
  }

  Future<TryOnCombo> addItemToCombo({
    required int comboId,
    required int productId,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/profile/combos/$comboId/items/',
        data: {'product_id': productId},
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return TryOnCombo.fromJson(data);
    });
  }
}
