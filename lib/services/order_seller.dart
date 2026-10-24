import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kisekae/models/order_details.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class StoreOrderRepository extends BaseRepository {
  final Dio _dio;

  StoreOrderRepository([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Map<String, dynamic> _dataMap(dynamic body) {
    if (body is Map) {
      final inner = body['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(body);
    }
    throw const FormatException('Unexpected response from the server');
  }

  List<dynamic> _listOf(dynamic body) {
    final data = body is Map ? (body['data'] ?? body) : body;
    final raw = data is Map ? data['results'] : data;
    return raw is List ? raw : const [];
  }

  Future<List<OrderItemSummary>> getStoreOrders({
    required int storeId,
    String? search,
    String? status,
  }) async {
    return execute(() async {
      final queryParams = <String, dynamic>{'page_size': 50};

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _dio.get(
        '/stores/$storeId/orders/',
        queryParameters: queryParams,
      );

      return _listOf(response.data)
          .whereType<Map>()
          .map(
            (item) =>
                OrderItemSummary.fromJson(Map<String, dynamic>.from(item)),
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

      return OrderDetail.fromJson(_dataMap(response.data));
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
      // Empty strings are not sent: an empty tracking_url can fail the
      // backend's URL validation.
      final payload = <String, dynamic>{
        'status': status.toUpperCase(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (trackingNumber != null && trackingNumber.trim().isNotEmpty)
          'tracking_number': trackingNumber.trim(),
        if (trackingUrl != null && trackingUrl.trim().isNotEmpty)
          'tracking_url': trackingUrl.trim(),
      };

      final response = await _dio.patch(
        '/stores/$storeId/orders/$orderId/status/',
        data: payload,
        cancelToken: cancelToken,
      );
      debugPrint('ORDER STATUS RAW: ${response.data}'); // temporary

      // The PATCH returns the full updated order in `data`.
      return OrderDetail.fromJson(_dataMap(response.data));
    });
  }
}
