import 'package:dio/dio.dart';
import "package:bully_app/core/global_variables.dart";
import 'package:bully_app/features/nfc/data/models/nfc_response_model.dart';

class NfcRemoteDataSource {
  // Lo ideal es pasar la instancia de Dio por el constructor 
  // para facilitar pruebas unitarias e inyección de dependencias.
  final Dio _dio;
  final String _baseUrl = apiBaseUrl; // URL base de la API para NFC

  NfcRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  /// Envía el UID del chip al servidor para traer la información correspondiente
  Future<NfcResponseModel?> fetchDogInfoByUid(String uid) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/mobile/nfc/$uid',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // Dio maneja los estados 200-299 automáticamente como exitosos
      if (response.statusCode == 200 && response.data != null) {
        // ¡Aquí es donde ocurre la magia del mapeo!
        return NfcResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      
      return null;
    } on DioException catch (e) {
      // Manejo estricto de errores de red/servidor propios de Dio
      print("Error de Dio en NfcRemoteDataSource: ${e.message}");
      // Aquí podrías evaluar e.type para saber si fue timeout, error de respuesta 404/500, etc.
      return null;
    } catch (e) {
      // Captura cualquier otro error inesperado
      print("Error inesperado en NfcRemoteDataSource: $e");
      return null;
    }
  }
}