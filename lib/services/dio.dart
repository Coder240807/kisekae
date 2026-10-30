import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/services/storage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _RefreshResult {
  final String? token;
  const _RefreshResult(this.token);
}

class DioClient {
  DioClient._();

  static late final Dio dio;
  static late final PersistCookieJar cookieJar;
  static bool _initialized = false;
  static Future<_RefreshResult>? _refreshing;

  static const _refreshPath = '/accounts/token/refresh/';
  static const _noRefreshPaths = [
    '/accounts/login',
    '/accounts/register',
    '/accounts/otp',
    '/accounts/token/refresh',
    '/accounts/logout',
  ];

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static BaseOptions _baseOptions() =>
      BaseOptions(baseUrl: dotenv.get('BASE_URL'), headers: _jsonHeaders);

  static Future<void> init() async {
    if (_initialized) return;

    cookieJar = PersistCookieJar(storage: CookieStorage());
    dio = Dio(_baseOptions());

    dio.interceptors.addAll([
      CookieManager(cookieJar),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage().readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          final options = error.requestOptions;
          final isUnauthorized = error.response?.statusCode == 401;
          final hadAuth = options.headers.containsKey('Authorization');
          final skipRefresh =
              _noRefreshPaths.any(options.path.contains) ||
              options.extra['retried'] == true;

          if (isUnauthorized && hadAuth && !skipRefresh) {
            final result = await _refreshAccessToken();
            if (result.token != null) {
              options.headers['Authorization'] = 'Bearer ${result.token}';
              options.extra['retried'] = true;

              // A FormData can only be sent once, so give the retry a
              // fresh copy (covers image uploads and invites).
              final body = options.data;
              if (body is FormData) options.data = body.clone();

              try {
                return handler.resolve(await dio.fetch(options));
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
          }

          if (kDebugMode && !options.path.contains('/accounts/')) {
            debugPrint(
              '${options.method} ${options.path} -> ${error.response?.statusCode}\n'
              'sent: ${options.data}\n'
              'got: ${error.response?.data}',
            );
          }

          return handler.next(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: ApiException.fromDioException(error),
            ),
          );
        },
      ),
    ]);

    _initialized = true;
  }

  static Future<_RefreshResult> _refreshAccessToken() {
    return _refreshing ??= _requestNewAccessToken().whenComplete(
      () => _refreshing = null,
    );
  }

  static Future<_RefreshResult> _requestNewAccessToken() async {
    try {
      debugPrint('Refreshing access token...');
      final refreshDio = Dio(_baseOptions())
        ..interceptors.add(CookieManager(cookieJar));
      final response = await refreshDio.post(_refreshPath);

      final access = response.data?['data']?['access'];
      if (access is String && access.isNotEmpty) {
        await TokenStorage().write(access);
        return _RefreshResult(access);
      }
      await _expireSession();
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) await _expireSession();
    } catch (_) {}
    return const _RefreshResult(null);
  }

  static Future<void> _expireSession() async {
    debugPrint('Session expired. Logging out.');
    await clearSession();
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/onboarding',
      (_) => false,
    );
  }

  static Future<void> clearSession() async {
    await TokenStorage().deleteAll();
    await cookieJar.deleteAll();
  }

  static Future<bool> refreshToken() async {
    final result = await _refreshAccessToken();
    return result.token != null;
  }
}
