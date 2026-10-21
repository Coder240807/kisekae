import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _isSellerKey = 'is_seller';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> write(String accessToken) =>
      _storage.write(key: _accessTokenKey, value: accessToken);

  Future<void> saveIsSeller(bool value) =>
      _storage.write(key: _isSellerKey, value: value.toString());

  Future<bool> readIsSeller() async =>
      (await _storage.read(key: _isSellerKey)) == 'true';

  Future<void> deleteAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _isSellerKey);
  }
}

class CookieStorage implements Storage {
  final _secureStorage = const FlutterSecureStorage();

  @override
  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    await Future.wait(keys.map((key) => _secureStorage.delete(key: key)));
  }

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}
}
