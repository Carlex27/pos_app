import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Singleton
  static final TokenStorage _instance = TokenStorage._internal();
  factory TokenStorage() => _instance;
  TokenStorage._internal();

  final _secureStorage = const FlutterSecureStorage();

  // Keys
  static const _keyAccessToken  = 'ACCESS_TOKEN';
  static const _keyRefreshToken = 'REFRESH_TOKEN';

  Future<void> saveAccessToken(String token) =>
      _secureStorage.write(key: _keyAccessToken, value: token);

  Future<void> saveRefreshToken(String token) =>
      _secureStorage.write(key: _keyRefreshToken, value: token);

  Future<String?> readAccessToken() =>
      _secureStorage.read(key: _keyAccessToken);

  Future<String?> readRefreshToken() =>
      _secureStorage.read(key: _keyRefreshToken);

  Future<void> deleteTokens() =>
      Future.wait([
        _secureStorage.delete(key: _keyAccessToken),
        _secureStorage.delete(key: _keyRefreshToken),
      ]);
}
