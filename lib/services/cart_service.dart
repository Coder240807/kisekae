import 'package:dio/dio.dart';
import 'package:kisekae/models/cart.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class CartService extends BaseRepository {
  final Dio _dio;

  CartService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<CartModel> getCart({String? cartToken}) async {
    return execute(() async {
      final response = await _dio.get(
        '/profile/cart/',
        options: Options(
          headers: {
            if (cartToken != null && cartToken.isNotEmpty)
              'X-Cart-Token': cartToken,
          },
        ),
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return CartModel.fromJson(data);
    });
  }

  Future<CartModel> clearCart({String? cartToken}) async {
    return execute(() async {
      final response = await _dio.delete(
        '/profile/cart/clear/',
        options: Options(
          headers: {
            if (cartToken != null && cartToken.isNotEmpty)
              'X-Cart-Token': cartToken,
          },
        ),
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return CartModel.fromJson(data);
    });
  }

  Future<CartModel> addToCart({
    required int productId,
    String? size,
    int quantity = 1,
    String? cartToken,
  }) async {
    return execute(() async {
      final payload = {
        'product_id': productId,
        'size': size ?? '',
        'quantity': quantity,
      };

      final response = await _dio.post(
        '/profile/cart/items/',
        data: payload,
        options: Options(
          headers: {
            if (cartToken != null && cartToken.isNotEmpty)
              'X-Cart-Token': cartToken,
          },
        ),
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return CartModel.fromJson(data);
    });
  }

  Future<CartModel> updateItemQuantity({
    required int itemId,
    required int quantity,
    String? cartToken,
  }) async {
    return execute(() async {
      final response = await _dio.patch(
        '/profile/cart/items/$itemId/',
        data: {'quantity': quantity},
        options: Options(
          headers: {
            if (cartToken != null && cartToken.isNotEmpty)
              'X-Cart-Token': cartToken,
          },
        ),
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return CartModel.fromJson(data);
    });
  }

  Future<CartModel> removeCartItem({
    required int itemId,
    String? cartToken,
  }) async {
    return execute(() async {
      final response = await _dio.delete(
        '/profile/cart/items/$itemId/',
        options: Options(
          headers: {
            if (cartToken != null && cartToken.isNotEmpty)
              'X-Cart-Token': cartToken,
          },
        ),
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return CartModel.fromJson(data);
    });
  }

  Future<CartValidationResult> validateCart({String? cartToken}) async {
    return execute(() async {
      final response = await _dio.get(
        '/profile/cart/validate/',
        options: Options(
          headers: {
            if (cartToken != null && cartToken.isNotEmpty)
              'X-Cart-Token': cartToken,
          },
        ),
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return CartValidationResult.fromJson(data);
    });
  }
}
