import 'package:dio/dio.dart';
import 'package:kisekae/services/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AuthResponse(this.success, this.message, [this.data]);
}

class EmailAuth {
  final Dio dio = Dio(BaseOptions(baseUrl: dotenv.get('BASE_URL')))
    ..interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            print("Session Expired. Logging Out...");
            await TokenStorage().deleteAll();
            return handler.next(error);
          }
          if (error.response?.statusCode == 500) {
            print("Server Error");
          }
          return handler.next(error);
        },
      ),
    );

  final TokenStorage _tokenStorage = TokenStorage();

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await dio.post(
        '/accounts/login/password/',
        data: {"email": email, "password": password},
      );
      print(response);
      if (!await _saveTokens(response.headers)) {
        return AuthResponse(false, "Tokens missing from response headers.");
      } else {
        return AuthResponse(
          true,
          response.data["message"]?.toString() ?? "",
          Map<String, dynamic>.from(response.data["data"] ?? {}),
        );
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      return AuthResponse(
        false,
        body is Map
            ? body["message"].toString()
            : (e.message ?? "Network error"),
      );
    } catch (e) {
      return AuthResponse(false, "Unexpected error: $e");
    }
  }

  Future<AuthResponse> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '/accounts/register/',
        data: {"name": name, "email": email, "password": password},
      );
      return AuthResponse(
        true,
        response.data["message"]?.toString() ?? "",
        Map<String, dynamic>.from(response.data["data"] ?? {}),
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      return AuthResponse(
        false,
        body is Map
            ? body["message"].toString()
            : (e.message ?? "Network error"),
      );
    } catch (e) {
      return AuthResponse(false, "Unexpected error: $e");
    }
  }

  Future<AuthResponse> sendOtp(String email, {String purpose = "login"}) async {
    try {
      final response = await dio.post(
        '/accounts/otp/request/',
        data: {"email": email, "purpose": purpose},
      );
      print(response);
      return AuthResponse(true, response.data["message"]?.toString() ?? "");
    } on DioException catch (e) {
      final body = e.response?.data;
      return AuthResponse(
        false,
        body is Map
            ? body["message"].toString()
            : (e.message ?? "Network error"),
      );
    } catch (e) {
      return AuthResponse(false, "Unexpected error: $e");
    }
  }

  Future<AuthResponse> verifyOtp(String email, int code, {required String purpose}) async {
    try {
      final response = await dio.post(
        '/accounts/otp/verify/',
        data: {"email": email, "code": code, "purpose": purpose},
      );
      if (purpose == "login") {
        if (!await _saveTokens(response.headers)) {
          return AuthResponse(false, "Tokens missing from response headers.");
        }
      }
      return AuthResponse(
        true,
        response.data["message"]?.toString() ?? "",
        Map<String, dynamic>.from(response.data["data"] ?? {}),
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      return AuthResponse(
        false,
        body is Map
            ? body["message"].toString()
            : (e.message ?? "Network error"),
      );
    } catch (e) {
      return AuthResponse(false, "Unexpected error: $e");
    }
  }

  Future<AuthResponse> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await dio.post(
        '/accounts/password/reset/',
        data: {"token": token, "new_password": newPassword},
      );
      return AuthResponse(true, response.data["message"]?.toString() ?? "");
    } on DioException catch (e) {
      final body = e.response?.data;
      return AuthResponse(
        false,
        body is Map
            ? body["message"].toString()
            : (e.message ?? "Network error"),
      );
    } catch (e) {
      return AuthResponse(false, "Unexpected error: $e");
    }
  }

  Future<AuthResponse> logout() async {
    try {
      final accessToken = await _tokenStorage.readAccessToken();
      final refreshToken = await _tokenStorage.readRefreshToken();

      final response = await dio.post(
        '/accounts/logout/',
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "X-Refresh-Token": refreshToken,
          },
        ),
      );
      await _tokenStorage.deleteAll();
      return AuthResponse(true, response.data["message"]?.toString() ?? "");
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.deleteAll();
        return AuthResponse(true, "Session already expired.");
      }
      final body = e.response?.data;
      return AuthResponse(
        false,
        body is Map
            ? body["message"].toString()
            : (e.message ?? "Logout failed"),
      );
    } catch (e) {
      return AuthResponse(false, "Unexpected error: $e");
    }
  }

  Future<bool> _saveTokens(Headers headers) async {
    final authHeader = headers.value('authorization');
    final refreshToken = headers.value('x-refresh-token');

    if (authHeader == null || refreshToken == null) {
      return false;
    }

    final accessToken = authHeader.toLowerCase().startsWith('bearer ')
        ? authHeader.substring(7).trim()
        : authHeader.trim();

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      return false;
    }

    await _tokenStorage.write(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return true;
  }
}
