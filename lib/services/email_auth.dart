import 'package:dio/dio.dart';
import 'package:kisekae/services/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailAuth {
  final dio = Dio(BaseOptions(baseUrl: dotenv.get('BASE_URL')));
  final TokenStorage _tokenStorage = TokenStorage();

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await dio.post(
        '/accounts/login/password/',
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final String accessToken = data["tokens"]["access"];
        final String refreshToken = data["tokens"]["refresh"];

        _tokenStorage.write(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        return true;
      } else {
        print("Auth Error: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      print("Auth Error: $e");
    }
    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      final response = await dio.post(
        '/accounts/register/',
        data: {"name": name, "email": email, "password": password},
      );

      if (response.statusCode == 201) {
        final data = response.data;

        final String accessToken = data["tokens"]["access"];
        final String refreshToken = data["tokens"]["refresh"];

        _tokenStorage.write(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        return true;
      } else {
        print("Auth Error: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      print("Auth Error: $e");
    }
    return false;
  }

  Future<bool> sendOtp(String email, {String purpose = "login"}) async {
    try {
      final response = await dio.post(
        '/accounts/otp/request/',
        data: {"email": email, "purpose": purpose},
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Auth Error: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      print("Auth Error: $e");
    }
    return false;
  }

  Future<bool> verifyOtp(String email, int code) async {
    try {
      final response = await dio.post(
        '/accounts/otp/verify/',
        data: {"email": email, "code": code},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final String accessToken = data["tokens"]["access"];
        final String refreshToken = data["tokens"]["refresh"];

        _tokenStorage.write(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        return true;
      } else {
        print("Auth Error: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      print("Auth Error: $e");
    }
    return false;
  }

  Future<bool> resetPassword(String email, int code, String newPassword) async {
    try {
      final response = await dio.post(
        '/accounts/password/reset/',
        data: {"email": email, "code": code, "new_password": newPassword},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Auth Error: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      print("Auth Error: $e");
    }
    return false;
  }

  Future<bool> logout() async {
    try {
      final accessToken = await _tokenStorage.readAccessToken();
      final refreshToken = await _tokenStorage.readRefreshToken();
      print("$accessToken, $refreshToken");
      final response = await dio.post(
        '/accounts/logout/',
        data: {"refresh": refreshToken},
        options: Options(headers: {"Authorization": "Bearer $accessToken"}),
      );
      if (response.statusCode == 200) {
        await _tokenStorage.deleteAll();
        return true;
      } else {
        print("Logout Error: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      print("Logout Error: $e");
    }
    return false;
  }
}
