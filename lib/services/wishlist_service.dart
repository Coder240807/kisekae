import 'package:dio/dio.dart';
import 'package:kisekae/models/wishlist.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class WishlistService extends BaseRepository {
  final Dio _dio;

  WishlistService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<WishlistItem>> getWishlistItems() async {
    return execute(() async {
      final response = await _dio.get('/accounts/wishlist/');

      final body = Map<String, dynamic>.from(response.data as Map);
      final list = body['data'] as List<dynamic>;

      return list
          .map(
            (item) =>
                WishlistItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    });
  }

  Future<WishlistItem> addToWishlist({
    required int productId,
    String note = '',
  }) async {
    return execute(() async {
      final payload = {'product_id': productId, 'note': note};

      final response = await _dio.post('/accounts/wishlist/', data: payload);

      final body = Map<String, dynamic>.from(response.data as Map);
      final itemData = Map<String, dynamic>.from(body['data'] as Map);

      return WishlistItem.fromJson(itemData);
    });
  }

  Future<String> clearWishlist() async {
    return execute(() async {
      final response = await _dio.delete('/accounts/wishlist/');

      final body = Map<String, dynamic>.from(response.data as Map);
      final message =
          body['message']?.toString() ?? 'Wishlist cleared successfully.';

      return message;
    });
  }

  Future<String> removeWishlistItem(int productId) async {
    return execute(() async {
      final response = await _dio.delete('/accounts/wishlist/$productId/');

      final body = Map<String, dynamic>.from(response.data as Map);
      final message =
          body['message']?.toString() ??
          'Item removed from wishlist successfully.';

      return message;
    });
  }

  Future<MoveToCartResult> moveToCart(int productId) async {
    return execute(() async {
      final response = await _dio.post(
        '/accounts/wishlist/$productId/move-to-cart/',
      );
      final body = Map<String, dynamic>.from(response.data as Map);
      return MoveToCartResult.fromJson(body);
    });
  }

  Future<BulkMoveToCartResult> bulkMoveToCart(List<int> productIds) async {
    return execute(() async {
      final payload = {'product_ids': productIds};

      final response = await _dio.post(
        '/accounts/wishlist/move-to-cart/',
        data: payload,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      return BulkMoveToCartResult.fromJson(body);
    });
  }
}
