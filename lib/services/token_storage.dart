import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> write({required String accessToken}) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
    ]);
  }

  Future<void> deleteAll() async {
    await Future.wait([_storage.delete(key: _accessTokenKey)]);
  }
}
