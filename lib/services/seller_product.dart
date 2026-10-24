import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kisekae/models/seller_product.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class HandleProduct extends BaseRepository {
  final Dio _dio;

  HandleProduct([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Map<String, dynamic>? _dataMap(dynamic body) {
    if (body is Map) {
      final inner = body['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return Map<String, dynamic>.from(body);
    }
    return null;
  }

  Map<String, dynamic>? _paginated(dynamic body) {
    if (body is Map) {
      final inner = body['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      if (inner is List) return {'count': inner.length, 'results': inner};
      return Map<String, dynamic>.from(body);
    }
    if (body is List) return {'count': body.length, 'results': body};
    return null;
  }

  List<dynamic> _dataList(dynamic body) {
    if (body is Map) {
      final inner = body['data'];
      if (inner is List) return inner;
      return [];
    }
    if (body is List) return body;
    return [];
  }

  Future<PaginatedProductResponse> getStoreProducts({
    required int storeId,
    int? page,
    int? pageSize,
    String? search,
    String? status,
  }) async {
    return execute(() async {
      final queryParams = <String, dynamic>{
        if (page != null) 'page': page,
        if (pageSize != null) 'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      };

      final response = await _dio.get(
        '/stores/$storeId/products/',
        queryParameters: queryParams,
      );

      return PaginatedProductResponse.fromJson(_paginated(response.data)!);
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

      return Product.fromJson(_dataMap(response.data)!);
    });
  }

  Future<Product> getProductDetails({
    required int storeId,
    required int productId,
  }) async {
    return execute(() async {
      final response = await _dio.get('/stores/$storeId/products/$productId/');
      return Product.fromJson(_dataMap(response.data)!);
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

      return Product.fromJson(_dataMap(response.data)!);
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

      return Product.fromJson(_dataMap(response.data)!);
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

      if (response.data is Map) {
        final body = Map<String, dynamic>.from(response.data as Map);
        return body['message'] as String? ??
            'Primary image removed successfully';
      }
      return 'Primary image removed successfully';
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

      final list = _dataList(response.data);

      final images = list
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

      final list = _dataList(response.data);

      return list
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

      if (response.data is Map) {
        final body = Map<String, dynamic>.from(response.data as Map);
        return body['success'] as bool? ?? true;
      }
      return true;
    });
  }
}
