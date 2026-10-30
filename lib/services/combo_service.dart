import 'package:dio/dio.dart';
import 'package:kisekae/models/recommend_combos.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class ComboService extends BaseRepository {
  final Dio _dio;

  ComboService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<RecommendedComboResponse> getRecommendedCombos(int productPk) async {
    return execute(() async {
      final response = await _dio.get(
        '/products/$productPk/recommended-combos/',
      );

      final mapData = Map<String, dynamic>.from(response.data ?? {});
      return RecommendedComboResponse.fromJson(mapData);
    });
  }
}
