import 'package:dio/dio.dart';
import 'package:kisekae/models/invite.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class StoreInvitation extends BaseRepository {
  final Dio _dio;

  StoreInvitation([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<InvitationSellerStore>> getStoreInvitations({
    required int storeId,
    String? status,
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/stores/$storeId/invitations/',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      final List data = response.data as List;
      return data
          .map(
            (json) =>
                InvitationSellerStore.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<InvitationSellerStore> inviteSeller({
    required int storeId,
    required String email,
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/invitations/',
        data: {'email': email},
      );

      return InvitationSellerStore.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }

  Future<void> revokeInvitation({
    required int storeId,
    required int invitationId,
  }) async {
    return execute(() async {
      await _dio.delete('/stores/$storeId/invitations/$invitationId/');
    });
  }

  Future<InvitationSellerStore> resendInvitation({
    required int storeId,
    required int invitationId,
  }) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/invitations/$invitationId/resend/',
      );

      return InvitationSellerStore.fromJson(
        response.data as Map<String, dynamic>,
      );
    });
  }
}
