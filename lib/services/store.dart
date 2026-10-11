import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/store_create.dart';

class StoreException implements Exception {
  final int? statusCode;
  final bool success;
  final String message;
  final String? code;
  final String? details;

  StoreException({
    this.statusCode,
    required this.success,
    required this.message,
    this.code,
    this.details,
  });

  factory StoreException.fromDioException(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      return StoreException(
        statusCode: e.response?.statusCode,
        success: responseData['success'] as bool? ?? false,
        message: responseData['message'] as String? ?? 'An error occurred',
        code: responseData['error']?['code'] as String?,
        details: responseData['error']?['details'] as String?,
      );
    }
    return StoreException(
      statusCode: e.response?.statusCode,
      success: false,
      message: e.message ?? 'Network connection error',
    );
  }

  @override
  String toString() => '[$statusCode - $code] $message: $details';
}

class StoreOperations {
  final Dio _dio;

  StoreOperations({required Future<String?> Function() getToken})
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.get('BASE_URL'),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final storeException = StoreException.fromDioException(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: storeException,
            ),
          );
        },
      ),
    );
  }

  Future<T> _execute<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.error is StoreException) {
        throw e.error as StoreException;
      }
      throw StoreException(success: false, message: 'Request failed');
    }
  }

  Future<PaginatedStoreResponse> getStores({
    bool? includeArchived,
    int? page,
    int? pageSize,
    String? role,
    String? status,
  }) async {
    return _execute(() async {
      final queryParams = <String, dynamic>{
        'include_archived': ?includeArchived,
        'page': ?page,
        'page_size': ?pageSize,
        'role': ?role,
        'status': ?status,
      };

      final response = await _dio.get('/stores/', queryParameters: queryParams);

      return PaginatedStoreResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  Future<Store> createStore({
    required String name,
    required String description,
    required String contactEmail,
    required String contactPhone,
  }) async {
    return _execute(() async {
      final response = await _dio.post(
        '/stores/',
        data: {
          'name': name,
          'description': description,
          'contact_email': contactEmail,
          'contact_phone': contactPhone,
        },
      );
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> getStoreById(int storeId) async {
    return _execute(() async {
      final response = await _dio.get('/stores/$storeId');
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> updateStore({
    required int storeId,
    String? name,
    String? description,
    String? contactEmail,
    String? contactPhone,
  }) async {
    return _execute(() async {
      final payload = <String, dynamic>{
        'name': ?name,
        'description': ?description,
        'contact_email': ?contactEmail,
        'contact_phone': ?contactPhone,
      };
      final response = await _dio.patch('/stores/$storeId', data: payload);
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> archiveStore(int storeId) async {
    return _execute(() async {
      final response = await _dio.delete('/stores/$storeId/');
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> restoreStore(int storeId) async {
    return _execute(() async {
      final response = await _dio.post('/stores/$storeId/restore/');
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> uploadBanner({
    required int storeId,
    required File imageFile,
  }) async {
    return _execute(() async {
      final fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.put(
        '/stores/$storeId/banner/',
        data: formData,
      );

      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> deleteBanner(int storeId) async {
    return _execute(() async {
      final response = await _dio.delete('/stores/$storeId/banner/');
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> uploadLogo({
    required int storeId,
    required File imageFile,
  }) async {
    return _execute(() async {
      final fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.put('/stores/$storeId/logo/', data: formData);

      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> deleteLogo(int storeId) async {
    return _execute(() async {
      final response = await _dio.delete('/stores/$storeId/logo/');
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<List<StoreMember>> getStoreMembers(int storeId) async {
    return _execute(() async {
      final response = await _dio.get('/stores/$storeId/members/');
      final List data = response.data as List;
      return data
          .map((json) => StoreMember.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  Future<StoreMember> addStoreMember({
    required int storeId,
    required String email,
  }) async {
    return _execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/members/',
        data: {'email': email},
      );

      return StoreMember.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Map<String, dynamic>> removeStoreMember({
    required int storeId,
    required int memberId,
  }) async {
    return _execute(() async {
      final response = await _dio.delete('/stores/$storeId/members/$memberId/');
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Store> transferOwnership({
    required int storeId,
    required int memberId,
  }) async {
    return _execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/transfer-ownership/',
        data: {'member_id': memberId},
      );

      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
