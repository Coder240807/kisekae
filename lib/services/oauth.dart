import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:kisekae/services/token_storage.dart';

class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AuthResponse(this.success, this.message, [this.data]);
}

class SocialAuth {
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

  Future<AuthResponse> signInWithGoogle() {
    final callback = dotenv.get('GOOGLE_CALLBACK_URL');
    final state = _randomState();

    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    final url = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': dotenv.get('GOOGLE_CLIENT_ID'),
      'redirect_uri': callback,
      'response_type': 'code',
      'scope': 'openid email profile',
      'access_type': 'offline',
      'prompt': 'consent',
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });

    return _signIn(
      provider: 'Google',
      authUrl: url,
      callback: callback,
      state: state,
      path: '/accounts/oauth/google/',
      codeVerifier: codeVerifier,
    );
  }

  Future<AuthResponse> signInWithGitHub() {
    final callback = dotenv.get('GITHUB_CALLBACK_URL');
    final state = _randomState();

    final url = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': dotenv.get('GITHUB_CLIENT_ID'),
      'redirect_uri': callback,
      'scope': 'read:user user:email',
      'state': state,
    });

    return _signIn(
      provider: 'GitHub',
      authUrl: url,
      callback: callback,
      state: state,
      path: '/accounts/oauth/github/',
    );
  }

  Future<AuthResponse> _signIn({
    required String provider,
    required Uri authUrl,
    required String callback,
    required String state,
    required String path,
    String? codeVerifier,
  }) async {
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: Uri.parse(callback).scheme,
      );

      final params = Uri.parse(result).queryParameters;
      if (params['state'] != state) {
        return AuthResponse(false, "State mismatch. Please try again.");
      }
      if (params['error'] != null) {
        return AuthResponse(
          false,
          params['error_description'] ?? "$provider sign in failed.",
        );
      }
      final code = params['code'];
      if (code == null || code.isEmpty) {
        return AuthResponse(false, "$provider did not return an auth code.");
      }

      return await _exchangeCode(path, code, callback, codeVerifier);
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        return AuthResponse(false, "Sign in cancelled.");
      }
      return AuthResponse(false, "$provider sign in failed: ${e.message}");
    } on DioException catch (e) {
      return _dioError(e);
    } catch (e) {
      return AuthResponse(false, "Unexpected error: $e");
    }
  }

  Future<AuthResponse> _exchangeCode(
    String path,
    String code,
    String callbackUrl,
    String? codeVerifier
  ) async {
    final response = await dio.post(
      path,
      data: {
        "code": code,
        "callback_url": callbackUrl,
        if (codeVerifier != null) "code_verifier": codeVerifier,
      },
    );

    if (!await _saveTokens(response.headers)) {
      return AuthResponse(false, "Tokens missing from response headers.");
    }
    return AuthResponse(
      true,
      response.data["message"]?.toString() ?? "",
      Map<String, dynamic>.from(response.data["data"] ?? {}),
    );
  }

  AuthResponse _dioError(DioException e) {
    final body = e.response?.data;
    return AuthResponse(
      false,
      body is Map ? body["message"].toString() : (e.message ?? "Network error"),
    );
  }

  String _randomState() => base64UrlEncode(
    List<int>.generate(16, (_) => Random.secure().nextInt(256)),
  );

  String _generateCodeVerifier() => base64UrlEncode(
    List<int>.generate(32, (_) => Random.secure().nextInt(256)),
  ).replaceAll('=', '');

  String _generateCodeChallenge(String verifier) =>
      base64UrlEncode(sha256.convert(utf8.encode(verifier)).bytes)
          .replaceAll('=', '');

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
