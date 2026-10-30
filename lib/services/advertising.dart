import 'package:dio/dio.dart';
import 'package:kisekae/models/advertising.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class AdvertisingOperations extends BaseRepository {
  final Dio _dio;

  AdvertisingOperations([Dio? dio]) : _dio = dio ?? DioClient.dio;

  String _base(int storeId) => '/stores/$storeId/advertising';

  Map<String, dynamic> _unwrap(dynamic body) {
    final map = Map<String, dynamic>.from(body as Map);
    final data = map['data'];
    return data is Map ? Map<String, dynamic>.from(data) : map;
  }

  List<dynamic> _asList(dynamic body) {
    final map = Map<String, dynamic>.from(body as Map);
    final data = map['data'];
    if (data is List) return data;
    if (data is Map) {
      final results = data['results'];
      return results is List ? results : [data];
    }
    final results = map['results'];
    return results is List ? results : [];
  }

  Future<AdAnalytics> getAnalytics(int storeId, {int? month, int? year}) {
    return execute(() async {
      final r = await _dio.get(
        '${_base(storeId)}/analytics/',
        queryParameters: {'month': ?month, 'year': ?year},
      );
      return AdAnalytics.fromJson(_unwrap(r.data));
    });
  }

  Future<AdBudget> getBudget(int storeId) {
    return execute(() async {
      final r = await _dio.get('${_base(storeId)}/budget/');
      return AdBudget.fromJson(_unwrap(r.data));
    });
  }

  Future<AdBudget> setBudget(int storeId, double amount) {
    return execute(() async {
      final r = await _dio.patch(
        '${_base(storeId)}/budget/',
        data: {'monthly_advertising_budget': amount.toStringAsFixed(2)},
      );
      return AdBudget.fromJson(_unwrap(r.data));
    });
  }

  Future<List<PromotedProduct>> getPromotedProducts(int storeId) {
    return execute(() async {
      final r = await _dio.get('${_base(storeId)}/products/');
      return _asList(r.data)
          .whereType<Map>()
          .map((e) => PromotedProduct.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<void> promoteProducts(int storeId, List<int> productIds) {
    return execute(() async {
      await _dio.post(
        '${_base(storeId)}/products/',
        data: {'product_ids': productIds},
      );
    });
  }

  Future<void> setProductActive(int storeId, int productId, bool active) {
    return execute(() async {
      await _dio.patch(
        '${_base(storeId)}/products/$productId/',
        data: {'is_active': active},
      );
    });
  }

  Future<void> removeProduct(int storeId, int productId) {
    return execute(() async {
      await _dio.delete('${_base(storeId)}/products/$productId/');
    });
  }
}
