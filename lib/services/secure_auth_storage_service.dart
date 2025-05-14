import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

ValueNotifier<SecuredAuthStorage> securedAuthStorage = ValueNotifier(
  SecuredAuthStorage(),
);

class SecuredAuthStorage {
  // create storage
  static final _storage = FlutterSecureStorage();

  // keys
  static const _keyAccessToken = 'ACCESS_TOKEN';
  static const _keyRefreshToken = 'REFRESH_TOKEN';
  static const _keyAccessTokenExpiry = 'ACCESS_TOKEN_EXPIRY';
  static const _keyPassword = "PASSWORD";
  static const _keyUserEmail = "USEREMAIL";

  Future<void> saveAccessTokenWithExpiry({
    required String accessToken,
    required String expiry,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyAccessTokenExpiry, value: expiry);
  }

  Future<void> saveRefreshToken({required String refreshToken}) async {
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> readAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<DateTime?> getAccessTokenExpiry() async {
    final expiryString = await _storage.read(key: _keyAccessTokenExpiry);
    if (expiryString == null) return null;
    return DateTime.tryParse(expiryString);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> clearAllTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  /// saved the user password in secured auth
  Future<void> savePassword({required String password}) async {
    await _storage.write(key: _keyPassword, value: password);
  }

  // fetch the user password from secured auth
  Future<String?> readPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  /// saved the user email in secured auth
  Future<void> saveUserEmail({required String email}) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  // fetch the user email from secured auth
  Future<String?> readUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  // clear User email and password
  Future<void> clearUserEmailAndPassword() async {
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyPassword);
  }
}
