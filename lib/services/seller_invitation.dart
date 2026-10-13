import 'package:dio/dio.dart';
import 'package:kisekae/models/invite.dart';
import 'package:kisekae/models/store_member.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class SellerInvitation extends BaseRepository {
  final Dio _dio;

  SellerInvitation([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<InvitationSellerStore>> getMyPendingInvitations() async {
    return execute(() async {
      final response = await _dio.get('/stores/invitations/');

      final list = response.data as List<dynamic>;
      return list
          .map(
            (item) =>
                InvitationSellerStore.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<StoreMember> acceptInvitation({required int invitationId}) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/invitations/$invitationId/accept/',
      );

      return StoreMember.fromJson(response.data as Map<String, dynamic>);
    });
  }

  Future<void> declineInvitation({required int invitationId}) async {
    return execute(() async {
      await _dio.post('/stores/invitations/$invitationId/decline/');
    });
  }

  Future<StoreMember> acceptInvitationByToken({required String token}) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/invitations/accept-token/',
        data: {'token': token},
      );

      return StoreMember.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
