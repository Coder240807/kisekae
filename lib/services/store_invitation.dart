import 'package:dio/dio.dart';
import 'package:kisekae/models/store_invitation.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class StoreInvitations extends BaseRepository {
  final Dio _dio;

  StoreInvitations([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<StoreInvitation>> getInvitations() async {
    return execute(() async {
      final response = await _dio.get('/stores/invitations/');

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'] as List<dynamic>? ?? [];

      return data
          .map(
            (item) => StoreInvitation.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    });
  }

  Future<void> acceptInvitation(int invitationId) async {
    return execute(() async {
      await _dio.post('/stores/invitations/$invitationId/accept/');
    });
  }

  Future<void> declineInvitation(int invitationId) async {
    return execute(() async {
      await _dio.post('/stores/invitations/$invitationId/decline/');
    });
  }
}
