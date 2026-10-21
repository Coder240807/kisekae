import 'package:dio/dio.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class StoreRepository extends BaseRepository {
  final Dio _dio;

  StoreRepository([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<Map<String, dynamic>> getBusinessVerification({
    required int storeId,
  }) async {
    return execute(() async {
      final response = await _dio.get('/stores/$storeId/verification/');

      return response.data as Map<String, dynamic>;
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

      return response.data as Map<String, dynamic>;
    });
  }
}
