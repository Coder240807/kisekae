import 'package:dio/dio.dart';
import 'package:kisekae/models/userprofile.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class ProfileDetails extends BaseRepository {
  final Dio _dio;

  ProfileDetails([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<UserProfile> getProfile() async {
    return execute(() async {
      final response = await _dio.get('/accounts/profile/');

      final body = Map<String, dynamic>.from(response.data as Map);
      final profileData = Map<String, dynamic>.from(body['data'] as Map);

      return UserProfile.fromJson(profileData);
    });
  }

  Future<UserProfile> updateProfileName(String name) async {
    return execute(() async {
      final response = await _dio.patch(
        '/accounts/profile/',
        data: {'name': name},
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final profileData = Map<String, dynamic>.from(body['data'] as Map);

      return UserProfile.fromJson(profileData);
    });
  }

  Future<String> deleteAccount() async {
    return execute(() async {
      final response = await _dio.delete('/accounts/profile/');

      final body = Map<String, dynamic>.from(response.data as Map);
      final message =
          body['message']?.toString() ?? 'Account deactivated successfully.';

      await DioClient.clearSession();

      return message;
    });
  }
}
