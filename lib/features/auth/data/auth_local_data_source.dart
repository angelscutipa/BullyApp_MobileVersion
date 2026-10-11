import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPrefs;

  AuthLocalDataSource({
    required this.secureStorage,
    required this.sharedPrefs,
  });

  // Guardar sesión tras el login
  Future<void> saveSession(String token, Map<String, dynamic> user) async {
    await secureStorage.write(key: 'auth_token', value: token);
    await sharedPrefs.setString('auth_token', token);
    await sharedPrefs.setString('cached_user', jsonEncode(user));
  }

  // Obtener el token para Dio o verificar si hay sesión
  Future<String?> getToken() async {
    final token = await secureStorage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) return token;
    return sharedPrefs.getString('auth_token');
  }

  // Cerrar sesión
  Future<void> clearSession() async {
    await secureStorage.delete(key: 'auth_token');
    await sharedPrefs.remove('auth_token');
    await sharedPrefs.remove('cached_user');
  }
}