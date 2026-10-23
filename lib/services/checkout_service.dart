import 'package:dio/dio.dart';
import 'package:kisekae/models/checkout.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class CheckoutService extends BaseRepository {
  final Dio _dio;

  CheckoutService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<CheckoutResponse> checkoutCart({
    int? addressId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? shippingAddress,
    String? notes,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final payload = <String, dynamic>{
        if (addressId != null) 'address_id': addressId,
        if (customerName != null && customerName.isNotEmpty)
          'customer_name': customerName,
        if (customerEmail != null && customerEmail.isNotEmpty)
          'customer_email': customerEmail,
        if (customerPhone != null && customerPhone.isNotEmpty)
          'customer_phone': customerPhone,
        if (shippingAddress != null && shippingAddress.isNotEmpty)
          'shipping_address': shippingAddress,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await _dio.post(
        '/cart/checkout/',
        data: payload,
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final checkoutData = Map<String, dynamic>.from(body['data'] as Map);

      return CheckoutResponse.fromJson(checkoutData);
    });
  }
}
