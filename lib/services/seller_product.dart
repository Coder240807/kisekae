import 'package:dio/dio.dart';
import 'package:kisekae/models/seller_product.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class HandleProduct extends BaseRepository {
  final Dio _dio;

  HandleProduct([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<PaginatedProductResponse> getStoreProducts({
    required int storeId,
    int? page,
    int? pageSize,
    String? search,
    String? status,
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/stores/$storeId/products/',
        queryParameters: {
          'page': ?page,
          'page_size': ?pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      return PaginatedProductResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  Future<Product> createProduct({
    required int storeId,
    required String name,
    required String price,
    String? description,
    String? imageUrl,
    String? compareAtPrice,
    String currency = 'INR',
    String? sku,
    int stock = 0,
    String status = 'DRAFT',
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/products/',
        data: {
          'name': name,
          'price': price,
          'description': ?description,
          'image_url': ?imageUrl,
          'compare_at_price': ?compareAtPrice,
          'currency': currency,
          'sku': ?sku,
          'stock': stock,
          'status': status,
        },
      );

      return Product.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Product> getProductDetails({
    required int storeId,
    required int productId,
  }) async {
    return execute(() async {
      final response = await _dio.get('/stores/$storeId/products/$productId/');

      return Product.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Product> updateProduct({
    required int storeId,
    required int productId,
    String? name,
    String? description,
    String? price,
    String? compareAtPrice,
    String? currency,
    String? sku,
    int? stock,
    String? status,
  }) async {
    return execute(() async {
      final response = await _dio.patch(
        '/stores/$storeId/products/$productId/',
        data: {
          'name': ?name,
          'description': ?description,
          'price': ?price,
          'compare_at_price': ?compareAtPrice,
          'currency': ?currency,
          'sku': ?sku,
          'stock': ?stock,
          'status': ?status,
        },
      );

      return Product.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<void> deleteProduct({
    required int storeId,
    required int productId,
  }) async {
    return execute(() async {
      await _dio.delete('/stores/$storeId/products/$productId/');
    });
  }

  Future<Product> uploadProductImage({
    required int storeId,
    required int productId,
    required String filePath,
    ProgressCallback? onSendProgress,
  }) async {
    return execute(() async {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.put(
        '/stores/$storeId/products/$productId/image/',
        data: formData,
        onSendProgress: onSendProgress,
      );

      return Product.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<void> removeProductImage({
    required int storeId,
    required int productId,
  }) async {
    return execute(() async {
      await _dio.delete('/stores/$storeId/products/$productId/image/');
    });
  }
}
