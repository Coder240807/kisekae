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
    if (body is List) return body;
    if (body is Map) {
      final inner = body['data'];
      if (inner is List) return inner;
      if (inner is Map && inner['results'] is List) {
        return inner['results'] as List;
      }
      if (body['results'] is List) return body['results'] as List;
    }
    return [];
  }

  Future<List<Product>> getStoreProducts({
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

      final list = _dataList(response.data);
      return list
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
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
    String? productType,
    String? description,
    String? price,
    String? compareAtPrice,
    String? currency,
    String? sku,
    String? status,
    List<VariantInput>? variants,
  }) async {
    return execute(() async {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (category != null) payload['category'] = category;
      if (productType != null) payload['product_type'] = productType;
      if (description != null) payload['description'] = description;
      if (price != null) payload['price'] = price;
      if (compareAtPrice != null) payload['compare_at_price'] = compareAtPrice;
      if (currency != null) payload['currency'] = currency;
      if (sku != null) payload['sku'] = sku;
      if (status != null) payload['status'] = status;
      if (variants != null) {
        payload['variants'] = variants.map((v) => v.toJson()).toList();
      }

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

  Future<Product> addStock({
    required int storeId,
    required int productId,
    required int delta,
    required int variantId,
    required String size,
    String reason = 'RESTOCK',
    String notes = '',
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/products/$productId/stock/add/',
        data: {
          'delta': delta,
          'variant_id': variantId,
          'size': size,
          'reason': reason,
          'notes': notes,
        },
      );
      final outer = _dataMap(response.data);
      final productMap = outer?['product'] as Map<String, dynamic>?;
      return Product.fromJson(productMap ?? outer!);
    });
  }

  Future<Product> removeStock({
    required int storeId,
    required int productId,
    required int delta,
    required int variantId,
    required String size,
    String reason = 'SALE',
    String notes = '',
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/products/$productId/stock/remove/',
        data: {
          'delta': delta,
          'variant_id': variantId,
          'size': size,
          'reason': reason,
          'notes': notes,
        },
      );
      final outer = _dataMap(response.data);
      final productMap = outer?['product'] as Map<String, dynamic>?;
      return Product.fromJson(productMap ?? outer!);
    });
  }

  Future<Product> adjustStock({
    required int storeId,
    required int productId,
    int? stock,
    int? adjustment,
    String reason = 'ADJUSTMENT',
    String notes = '',
  }) async {
    return execute(() async {
      final payload = <String, dynamic>{'reason': reason, 'notes': notes};
      if (stock != null) payload['stock'] = stock;
      if (adjustment != null) payload['adjustment'] = adjustment;

      final response = await _dio.patch(
        '/stores/$storeId/products/$productId/stock/',
        data: payload,
      );
      final outer = _dataMap(response.data);
      final productMap = outer?['product'] as Map<String, dynamic>?;
      return Product.fromJson(productMap ?? outer!);
    });
  }

  Future<List<ProductVariantImage>> getVariantImages({
    required int storeId,
    required int productId,
    required int variantId,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/stores/$storeId/products/$productId/variants/$variantId/images/',
        cancelToken: cancelToken,
      );

      final list = _dataList(response.data);
      return list
          .map(
            (item) =>
                ProductVariantImage.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    });
  }

  Future<ProductVariantImage> uploadVariantImage({
    required int storeId,
    required int productId,
    required int variantId,
    required File imageFile,
    int? order,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        if (order != null) 'order': order,
      });

      final response = await _dio.post(
        '/stores/$storeId/products/$productId/variants/$variantId/images/',
        data: formData,
        cancelToken: cancelToken,
      );

      final data = _dataMap(response.data);
      if (data != null) return ProductVariantImage.fromJson(data);
      return ProductVariantImage.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  Future<Product> deleteVariantImage({
    required int storeId,
    required int productId,
    required int variantId,
    required int imageId,
    CancelToken? cancelToken,
  }) async {
    return execute(() async {
      final response = await _dio.delete(
        '/stores/$storeId/products/$productId/variants/$variantId/images/$imageId/',
        cancelToken: cancelToken,
      );
      return Product.fromJson(_dataMap(response.data)!);
    });
  }
}
