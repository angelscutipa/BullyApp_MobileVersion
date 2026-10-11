import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bully_app/core/global_variables.dart';
import '../models/animal_detail_response_model.dart';

class AnimalRemoteDataSource {
  final Dio _dio;
  final String _baseUrl = apiBaseUrl;

  AnimalRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  /// Consulta los detalles y el ID del animal mediante GET a /mobile/animals/{animalId}
  Future<AnimalDetailResponseModel?> getAnimalDetails(int animalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print("Error: No hay token de autenticación guardado.");
        return null;
      }

      final response = await _dio.get(
        '$_baseUrl/mobile/animals/$animalId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        print(response.data);
        return AnimalDetailResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      return null;
    } on DioException catch (e) {
      print("Error de Dio en AnimalRemoteDataSource: ${e.message}");
      if (e.response != null) {
        print("Detalle del error del servidor: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      print("Error inesperado en AnimalRemoteDataSource: $e");
      return null;
    }
  }
}
