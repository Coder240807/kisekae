import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kisekae/models/store_member.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

import '../models/store_create.dart';

class StoreOperations extends BaseRepository {
  final Dio _dio;

  StoreOperations([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<PaginatedStoreResponse> getStores({
    bool? includeArchived,
    int? page,
    int? pageSize,
    String? role,
    String? status,
  }) async {
    return execute(() async {
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
    return execute(() async {
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
    return execute(() async {
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
    return execute(() async {
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

  Future<void> archiveStore({required int storeId}) async {
    return execute(() async {
      await _dio.delete('/stores/$storeId/');
    });
  }

  Future<Store> restoreStore(int storeId) async {
    return execute(() async {
      final response = await _dio.post('/stores/$storeId/restore/');
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> uploadBanner({
    required int storeId,
    required File imageFile,
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
        '/stores/$storeId/banner/',
        data: formData,
      );

      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> deleteBanner(int storeId) async {
    return execute(() async {
      final response = await _dio.delete('/stores/$storeId/banner/');
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<Store> uploadLogo({
    required int storeId,
    required File imageFile,
  }) async {
    return execute(() async {
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
    return execute(() async {
      final response = await _dio.delete('/stores/$storeId/logo/');
      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<List<StoreMember>> getStoreMembers(int storeId) async {
    return execute(() async {
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
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/members/',
        data: {'email': email},
      );

      return StoreMember.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<void> removeMember({
    required int storeId,
    required int memberId,
  }) async {
    return execute(() async {
      await _dio.delete('/stores/$storeId/members/$memberId/');
    });
  }

  Future<Store> transferOwnership({
    required int storeId,
    required int memberId,
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/transfer-ownership/',
        data: {'member_id': memberId},
      );

      return Store.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
