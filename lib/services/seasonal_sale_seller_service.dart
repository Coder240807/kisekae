import 'package:dio/dio.dart';
import 'package:kisekae/models/seasonal_sale_seller.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class SeasonalSales extends BaseRepository {
  final Dio _dio;

  SeasonalSales([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Map<String, dynamic> _dataMap(dynamic responseData) {
    final body = Map<String, dynamic>.from(responseData as Map);
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  Future<List<SeasonalSale>> getSales(
    int storeId, {
    String status = 'active',
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/stores/$storeId/seasonal-sales/',
        queryParameters: {'status': status},
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'] as List<dynamic>? ?? [];

      return data
          .map(
            (item) =>
                SeasonalSale.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    });
  }

  Future<SeasonalSale> getSale(int storeId, int saleId) async {
    return execute(() async {
      final response = await _dio.get(
        '/stores/$storeId/seasonal-sales/$saleId/',
      );
      return SeasonalSale.fromJson(_dataMap(response.data));
    });
  }

  Future<List<EnrolledProduct>> enrollProducts(
    int storeId,
    int saleId,
    List<int> productIds,
  ) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/seasonal-sales/$saleId/products/',
        data: {'product_ids': productIds},
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'] as List<dynamic>? ?? [];

      return data
          .map(
            (item) => EnrolledProduct.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    });
  }

  Future<EnrolledProduct> setProductActive(
    int storeId,
    int saleId,
    int productId,
    bool isActive,
  ) async {
    return execute(() async {
      final response = await _dio.patch(
        '/stores/$storeId/seasonal-sales/$saleId/products/$productId/',
        data: {'is_active': isActive},
      );
      return EnrolledProduct.fromJson(_dataMap(response.data));
    });
  }

  Future<void> removeProduct(int storeId, int saleId, int productId) async {
    return execute(() async {
      await _dio.delete(
        '/stores/$storeId/seasonal-sales/$saleId/products/$productId/',
      );
    });
  }
}
