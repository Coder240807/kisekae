import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/services/storage.dart';

class DioClient {
  DioClient._();

  static late final Dio dio;
  static late final PersistCookieJar cookieJar;
  static bool _initialized = false;
  static Future<String?>? _refreshing;

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

  static Future<void> init() async {
    if (_initialized) return;

    cookieJar = PersistCookieJar(storage: CookieStorage());
    dio = Dio(
      BaseOptions(baseUrl: dotenv.get('BASE_URL'), headers: _jsonHeaders),
    );

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
          var currentError = error;
          final options = error.requestOptions;

          final isUnauthorized = error.response?.statusCode == 401;

          if (kDebugMode && !options.path.contains('/accounts/')) {
            debugPrint(
              '${options.method} ${options.path} -> ${error.response?.statusCode}\n'
              'sent: ${options.data}\n'
              'got: ${error.response?.data}',
            );
          }
          final skipRefresh =
              _noRefreshPaths.any(options.path.contains) ||
              options.extra['retried'] == true;

          if (isUnauthorized && !skipRefresh) {
            final newToken = await _refreshAccessToken();
            if (newToken != null) {
              options.headers['Authorization'] = 'Bearer $newToken';
              options.extra['retried'] = true;
              try {
                final response = await dio.fetch(options);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                currentError = retryError;
              }
            } else {
              print("Session Expired. Logging Out...");
              await clearSession();
            }
          }

          if (currentError.response?.statusCode == 500) {
            print("Server Error");
          }

          final apiException = ApiException.fromDioException(currentError);
          final customError = DioException(
            requestOptions: currentError.requestOptions,
            response: currentError.response,
            type: currentError.type,
            error: apiException,
          );
          return handler.next(customError);
        },
      ),
    ]);

    _initialized = true;
  }

  static Future<String?> _refreshAccessToken() {
    return _refreshing ??= _requestNewAccessToken().whenComplete(
      () => _refreshing = null,
    );
  }

  static Future<String?> _requestNewAccessToken() async {
    try {
      final refreshDio = Dio(
        BaseOptions(baseUrl: dotenv.get('BASE_URL'), headers: _jsonHeaders),
      );
      refreshDio.interceptors.add(CookieManager(cookieJar));

      final response = await refreshDio.post(_refreshPath);

      final access = response.data?['data']?['access'];
      if (access is String && access.isNotEmpty) {
        await TokenStorage().write(access);
        return access;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clearSession() async {
    await TokenStorage().deleteAll();
    await cookieJar.deleteAll();
  }
}
