import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:odontologia_app/models/periodontograma_ai.dart';

class PeriodontogramaAiService {
  PeriodontogramaAiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

  final Dio _dio;

  static String get _baseUrl {
    final value = dotenv.env['AI_API_URL']?.trim() ?? '';
    if (value.isEmpty) {
      throw StateError('AI_API_URL no esta configurado en .env');
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  Future<PeriodontogramaAiTranscription> transcribirAudio(
    String filePath,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/asr/transcribe',
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[\\/]')).last,
        ),
      }),
    );
    return PeriodontogramaAiTranscription.fromJson(response.data!);
  }

  Future<PeriodontogramaAiResult> parsearTexto(String text) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/asr/parse',
      data: {'text': text},
    );
    return PeriodontogramaAiParseResponse.fromJson(
      response.data!,
    ).periodontogram;
  }
}
