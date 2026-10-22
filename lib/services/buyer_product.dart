import 'package:dio/dio.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/product_detail.dart';
import 'package:kisekae/models/seller_product.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class Product extends BaseRepository {
  final Dio _dio;

  Product({Dio? dio}) : _dio = dio ?? DioClient.dio;

  Future<PaginatedProductResponse> getPublicProducts({
    bool? inStock,
    String? letter,
    String? ordering,
    int? page,
    int? pageSize,
    String? search,
  }) {
    return execute(() async {
      final Map<String, dynamic> queryParams = {};

      if (inStock != null) queryParams['in_stock'] = inStock;
      if (letter != null && letter.isNotEmpty) queryParams['letter'] = letter;
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/products/',
        queryParameters: queryParams,
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        return PaginatedProductResponse.fromJson(responseData);
      }

      throw ApiException(
        statusCode: response.statusCode,
        success: false,
        message: 'Invalid response format received from server',
      );
    });
  }

  Future<ProductDetail> getPublicProductDetail(int productPk) {
    return execute(() async {
      final response = await _dio.get('/products/$productPk/');

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        return ProductDetail.fromJson(responseData);
      }

      throw ApiException(
        statusCode: response.statusCode,
        success: false,
        message: 'Invalid response format received from server',
      );
    });
  }

  Future<PaginatedProductResponse> searchProducts({
    String? query,
    String? letter,
    String? ordering,
    int? page,
    int? pageSize,
  }) {
    return execute(() async {
      final Map<String, dynamic> queryParams = {};

      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (letter != null && letter.isNotEmpty) queryParams['letter'] = letter;
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }
      if (page != null) queryParams['page'] = page;
      if (pageSize != null) queryParams['page_size'] = pageSize;

      final response = await _dio.get(
        '/products/search/',
        queryParameters: queryParams,
      );

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        return PaginatedProductResponse.fromJson(responseData);
      }

      throw ApiException(
        statusCode: response.statusCode,
        success: false,
        message: 'Invalid response format received from server',
      );
    });
  }
}
