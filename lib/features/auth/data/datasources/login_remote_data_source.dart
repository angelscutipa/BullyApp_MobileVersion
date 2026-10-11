// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bully_app/core/global_variables.dart';
import 'package:bully_app/features/auth/data/models/login_response_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;
  final String _baseUrl = apiBaseUrl; // URL base de la API

  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  /// Inicia sesión con correo y contraseña, y persiste token y usuario localmente.
  Future<LoginResponseModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/mobile/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print("JSON LOGIN: " + response.toString());

      if (response.statusCode == 200 && response.data != null) {
        final loginResponse = LoginResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        // Si la autenticación fue exitosa y tenemos token y usuario, los guardamos
        if (loginResponse.token != null && loginResponse.user != null) {
          await _saveSessionData(
            token: loginResponse.token!,
            user: loginResponse.user!,
          );
        }

        return loginResponse;
      }

      return null;
    } on DioException catch (e) {
      print("Error de Dio en AuthRemoteDataSource: ${e.message}");
      if (e.response != null) {
        print("Respuesta de error de la API: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      print("Error inesperado en AuthRemoteDataSource: $e");
      return null;
    }
  }

  /// Métodos auxiliares para persistencia local con SharedPreferences

  Future<void> _saveSessionData({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user));
  }

  /// Obtener el token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Obtener los datos del usuario guardados
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user_data');
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Cerrar sesión / Limpiar datos guardados
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
}