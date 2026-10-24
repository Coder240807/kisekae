import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
      final body = response.data;
      Map<String, dynamic> payload;
      if (body is Map<String, dynamic>) {
        final inner = body['data'];
        if (inner is Map<String, dynamic>) {
          payload = inner;
        } else if (inner is List) {
          payload = {'count': inner.length, 'results': inner};
        } else {
          payload = body;
        }
      } else {
        payload = {'count': 0, 'results': <dynamic>[]};
      }
      return PaginatedProductResponse.fromJson(payload);
    });
  }

  Future<Product> createProduct({
    required int storeId,
    required CreateProductRequest request,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/products/',
        data: request.toJson(),
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return Product.fromJson(data);
    });
  }

  Future<Product> getProductDetails({
    required int storeId,
    required int productId,
  }) async {
    return execute(() async {
      final response = await _dio.get('/stores/$storeId/products/$productId/');
      debugPrint('PRODUCT DETAIL RAW: ${response.data}'); // temporary

      final body = response.data;
      final data = body is Map ? (body['data'] ?? body) : body;
      return Product.fromJson(Map<String, dynamic>.from(data as Map));
    });
  }

  Future<Product> updateProduct({
    required int storeId,
    required int productId,
    String? name,
    String? category,
    String? color,
    String? description,
    String? price,
    String? compareAtPrice,
    String? currency,
    String? sku,
    int? stock,
    String? status,
  }) async {
    return execute(() async {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (category != null) payload['category'] = category;
      if (color != null) payload['color'] = color;
      if (description != null) payload['description'] = description;
      if (price != null) payload['price'] = price;
      if (compareAtPrice != null) payload['compare_at_price'] = compareAtPrice;
      if (currency != null) payload['currency'] = currency;
      if (sku != null) payload['sku'] = sku;
      if (stock != null) payload['stock'] = stock;
      if (status != null) payload['status'] = status;

      final response = await _dio.patch(
        '/stores/$storeId/products/$productId/',
        data: payload,
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

  Future<Product> uploadProductPrimaryImage({
    required int storeId,
    required int productId,
    required File imageFile,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.put(
        '/stores/$storeId/products/$productId/image/',
        data: formData,
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(body['data'] as Map);

      return Product.fromJson(data);
    });
  }

  Future<String> deleteProductPrimaryImage({
    required int storeId,
    required int productId,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.delete(
        '/stores/$storeId/products/$productId/image/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      return body['message'] as String? ?? 'Primary image removed successfully';
    });
  }

  Future<List<ProductImage>> getProductImages({
    required int storeId,
    required int productId,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/stores/$storeId/products/$productId/images/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final dataList = (body['data'] as List<dynamic>?) ?? [];

      final images = dataList
          .map((item) => ProductImage.fromJson(item as Map<String, dynamic>))
          .toList();

      images.sort((a, b) => a.order.compareTo(b.order));

      return images;
    });
  }

  Future<List<ProductImage>> uploadProductImages({
    required int storeId,
    required int productId,
    required List<File> imageFiles,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final formData = FormData();

      for (final file in imageFiles) {
        final fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }

      final response = await _dio.post(
        '/stores/$storeId/products/$productId/images/',
        data: formData,
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final dataList = (body['data'] as List<dynamic>?) ?? [];

      return dataList
          .map((item) => ProductImage.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<bool> deleteProductImage({
    required int storeId,
    required int productId,
    required int imageId,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.delete(
        '/stores/$storeId/products/$productId/images/$imageId/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      return body['success'] as bool? ?? true;
    });
  }
}
