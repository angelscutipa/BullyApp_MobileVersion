import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage secureStorage;

  AuthLocalDataSource({
    required this.secureStorage,
  });

  Future<void> saveToken(String token) async {
    await secureStorage.write(
      key: _tokenKey,
      value: token,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final token = await secureStorage.read(
      key: _tokenKey,
    );
    if (token != null && token.isNotEmpty) return token;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await secureStorage.delete(
      key: _tokenKey,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}