import 'package:dio/dio.dart';
import 'package:kisekae/models/order_details.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class StoreOrderRepository extends BaseRepository {
  final Dio _dio;

  StoreOrderRepository([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<OrderItemSummary>> getStoreOrders({
    required int storeId,
    String? search,
    String? status,
  }) async {
    return execute(() async {
      final queryParams = <String, dynamic>{};

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _dio.get(
        '/stores/$storeId/orders/',
        queryParameters: queryParams,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final list = body['data'] as List<dynamic>? ?? [];

      return list
          .map(
            (item) => OrderItemSummary.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    });
  }

  Future<OrderDetail> getOrderDetails({
    required int storeId,
    required int orderId,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/stores/$storeId/orders/$orderId/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return OrderDetail.fromJson(data);
    });
  }

  Future<OrderDetail> updateOrderStatus({
    required int storeId,
    required int orderId,
    required String status,
    String? notes,
    String? trackingNumber,
    String? trackingUrl,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final payload = <String, dynamic>{
        'status': status.toUpperCase(),
        if (notes != null) 'notes': notes,
        if (trackingNumber != null) 'tracking_number': trackingNumber,
        if (trackingUrl != null) 'tracking_url': trackingUrl,
      };

      final response = await _dio.patch(
        '/stores/$storeId/orders/$orderId/status/',
        data: payload,
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return OrderDetail.fromJson(data);
    });
  }
}
