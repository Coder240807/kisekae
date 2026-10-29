import 'package:dio/dio.dart';
import 'package:kisekae/models/invite.dart';

import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class StoreInvites extends BaseRepository {
  final Dio _dio;

  StoreInvites([Dio? dio]) : _dio = dio ?? DioClient.dio;

  SellerInvitation _parseInvitation(dynamic responseData) {
    final body = Map<String, dynamic>.from(responseData as Map);
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return SellerInvitation.fromJson(data);
  }

  Future<List<SellerInvitation>> getInvites(
    int storeId, {
    String? status,
    String? search,
    String ordering = '-created_at',
  }) async {
    return execute(() async {
      final response = await _dio.get(
        '/stores/$storeId/invitations/',
        queryParameters: {
          if (status != null) 'status': status,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          'ordering': ordering,
        },
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final data = body['data'] as List<dynamic>? ?? [];

      return data
          .map(
            (item) => SellerInvitation.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    });
  }

  Future<SellerInvitation> sendInvite(int storeId, String email) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/invitations/',
        data: FormData.fromMap({'email': email}),
      );
      return _parseInvitation(response.data);
    });
  }

  Future<void> revokeInvite(int storeId, int invitationId) async {
    return execute(() async {
      await _dio.delete('/stores/$storeId/invitations/$invitationId/');
    });
  }

  Future<SellerInvitation> resendInvite(int storeId, int invitationId) async {
    return execute(() async {
      final response = await _dio.post(
        '/stores/$storeId/invitations/$invitationId/resend/',
      );
      return _parseInvitation(response.data);
    });
  }
}
