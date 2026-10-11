// lib/features/nfc/data/datasources/link_chip_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bully_app/core/global_variables.dart';
import 'package:bully_app/features/nfc/data/models/link_chip_response_model.dart';

class LinkChipRemoteDataSource {
  final Dio _dio;
  final String _baseUrl = apiBaseUrl;

  LinkChipRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  /// Vincula un chip a un animal mediante POST a /mobile/animals/{animalId}/chip
  Future<LinkChipResponseModel?> linkChipToAnimal({
    required dynamic chipId, // Puede ser int o String según manejes el ID del chip
  }) async {
    try {
      // 1. Obtener el token de autenticación desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print("Error: No se encontró el token de autenticación.");
        return null;
      }

      // 2. Realizar la petición POST con el parámetro de ruta y el body
      final response = await _dio.post(
        '$_baseUrl/mobile/animals/$AnimalID/chip',
        data: {
          'chip_id': chipId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return LinkChipResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      print("Error de Dio en LinkChipRemoteDataSource: ${e.message}");
      if (e.response != null) {
        print("Detalle del error devuelto por la API: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      print("Error inesperado en LinkChipRemoteDataSource: $e");
      return null;
    }
  }
}