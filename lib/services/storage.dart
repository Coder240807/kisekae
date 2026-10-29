import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _isSellerKey = 'is_seller';
  static const _emailKey = 'user_email';
  static const _modeKey = 'app_mode';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> write(String accessToken) =>
      _storage.write(key: _accessTokenKey, value: accessToken);

  Future<void> saveIsSeller(bool value) =>
      _storage.write(key: _isSellerKey, value: value.toString());

  Future<bool> readIsSeller() async =>
      (await _storage.read(key: _isSellerKey)) == 'true';

  Future<void> saveEmail(String email) =>
      _storage.write(key: _emailKey, value: email);

  Future<String?> readEmail() => _storage.read(key: _emailKey);

  Future<void> deleteAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _isSellerKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _modeKey);
  }

  Future<void> deleteEmail() => _storage.delete(key: _emailKey);

  Future<void> saveMode(String mode) =>
      _storage.write(key: _modeKey, value: mode);

  Future<String?> readMode() => _storage.read(key: _modeKey);
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
