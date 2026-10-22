import 'package:dio/dio.dart';
import 'package:kisekae/models/order_details.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class StoreOrderRepository extends BaseRepository {
  final Dio _dio;

  StoreOrderRepository([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<PaginatedOrderResponse> getStoreOrders({
    required int storeId,
    int? page,
    int? pageSize,
    String? search,
    String? status,
  }) async {
    return execute(() async {
      final Map<String, dynamic> queryParams = {};

      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _dio.get(
        '/stores/$storeId/orders/',
        queryParameters: queryParams,
      );

      final responseData = response.data as Map<String, dynamic>;
      return PaginatedOrderResponse.fromJson(responseData);
    });
  }
}
