import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  final Dio dio;

  static String get _baseUrl {
    final value = dotenv.env['API_URL']?.trim() ?? '';
    if (value.isEmpty) {
      throw StateError('API_URL no esta configurado en .env');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
      return;
    }
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
}

String apiErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'La API no respondio a tiempo.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con la API.';
    }
  }
  return 'Ocurrio un error inesperado.';
}
