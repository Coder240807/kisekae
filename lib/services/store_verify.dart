import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class StoreRepository extends BaseRepository {
  final Dio _dio;

  StoreRepository([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Map<String, dynamic> _unwrap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final inner = body['data'];
      if (inner is Map<String, dynamic>) return inner;
      return body;
    }
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getBusinessVerification({
    required int storeId,
  }) async {
    return execute(() async {
      final response = await _dio.get('/stores/$storeId/verification/');
      final data = _unwrap(response.data);
      if (data.containsKey('status')) return data;

      final verification = data['verification'];
      if (verification is Map<String, dynamic>) {
        return {
          ...verification,
          'is_submitted': data['is_submitted'],
          'is_business_verified': data['is_business_verified'],
        };
      }

      return {
        'status': 'NOT_SUBMITTED',
        'is_submitted': false,
        'is_business_verified': data['is_business_verified'] == true,
      };
    });
  }

  Future<Map<String, dynamic>> submitBusinessVerification({
    required int storeId,
    required String panNumber,
    required String gstNumber,
    required String businessAddress,
    required String businessPhone,
    required String businessEmail,
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/verification/',
        data: {
          'pan_number': panNumber,
          'gst_number': gstNumber,
          'business_address': businessAddress,
          'business_phone': businessPhone,
          'business_email': businessEmail,
        },
      );
      return _unwrap(response.data);
    });
  }
}
