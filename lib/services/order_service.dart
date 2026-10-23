import 'package:dio/dio.dart';
import 'package:kisekae/models/customer_order.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class OrderService extends BaseRepository {
  final Dio _dio;

  OrderService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<CustomerOrderSummary>> getOrders({
    String? status,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final queryParams = <String, dynamic>{
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _dio.get(
        '/orders/',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final list = body['data'] as List<dynamic>? ?? [];

      return list
          .map(
            (item) => CustomerOrderSummary.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    });
  }

  Future<OrderDetail> getOrderDetail(
    int orderId, {
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/orders/$orderId/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return OrderDetail.fromJson(data);
    });
  }
}
