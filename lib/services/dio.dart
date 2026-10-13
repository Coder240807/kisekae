import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/services/storage.dart';

class DioClient {
  DioClient._();

  static late final Dio dio;
  static late final PersistCookieJar cookieJar;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    cookieJar = PersistCookieJar(storage: CookieStorage());
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('BASE_URL'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
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
          final hadAuthHeader = error.requestOptions.headers.containsKey(
            'Authorization',
          );

          if (error.response?.statusCode == 401 && hadAuthHeader) {
            print("Session Expired. Logging Out...");
            await clearSession();
          }
          if (error.response?.statusCode == 500) {
            print("Server Error");
          }

          final apiException = ApiException.fromDioException(error);
          final customError = DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: apiException,
          );
          return handler.next(customError);
        },
      ),
    ]);

    _initialized = true;
  }

  static Future<void> clearSession() async {
    await TokenStorage().deleteAll();
    await cookieJar.deleteAll();
  }
}
