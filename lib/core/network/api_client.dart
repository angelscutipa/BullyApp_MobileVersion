import 'package:dio/dio.dart';

import 'auth_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient({
    required AuthInterceptor authInterceptor,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: 'https://bullyapp.com.pe',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(authInterceptor);
  }
}