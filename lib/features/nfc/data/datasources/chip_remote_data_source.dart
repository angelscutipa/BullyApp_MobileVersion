// lib/features/nfc/data/datasources/chip_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bully_app/core/global_variables.dart';
import 'package:bully_app/features/nfc/data/models/chip_search_response_model.dart';

class ChipRemoteDataSource {
  final Dio _dio;
  final String _baseUrl = apiBaseUrl;

  ChipRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  /// Busca un chip por su consulta/código mediante GET a /mobile/chips/search?q={query}
  Future<ChipSearchResponseModel?> searchChip(String query) async {
    try {
      // 1. Obtenemos el token guardado en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print("Error: No hay token de autenticación guardado.");
        return null;
      }

      // 2. Realizamos la petición GET enviando el Query Parameter y el Bearer Token
      final response = await _dio.get(
        '$_baseUrl/mobile/chips/search',
        queryParameters: {'q': query},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return ChipSearchResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      print("Error de Dio en ChipRemoteDataSource: ${e.message}");
      if (e.response != null) {
        print("Detalle del error del servidor: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      print("Error inesperado en ChipRemoteDataSource: $e");
      return null;
    }
  }
}