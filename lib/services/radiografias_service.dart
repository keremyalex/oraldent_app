import 'package:dio/dio.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/radiografia.dart';

class RadiografiaRequest {
  const RadiografiaRequest({
    required this.titulo,
    this.descripcion,
    this.tipo,
    this.fechaEstudio,
    this.numeroFdi,
    this.zona,
    this.diagnosticoRadiografico,
    this.perdidaOseaObservada = false,
    this.tipoPerdidaOsea,
    this.severidadPerdidaOsea,
    this.porcentajePerdidaOseaEstimado,
    this.nivelCrestaOseaMm,
    this.observacionesPeriodontales,
  });

  final String titulo;
  final String? descripcion;
  final String? tipo;
  final DateTime? fechaEstudio;
  final int? numeroFdi;
  final String? zona;
  final String? diagnosticoRadiografico;
  final bool perdidaOseaObservada;
  final String? tipoPerdidaOsea;
  final String? severidadPerdidaOsea;
  final double? porcentajePerdidaOseaEstimado;
  final double? nivelCrestaOseaMm;
  final String? observacionesPeriodontales;

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'fechaEstudio': fechaEstudio == null ? null : _formatDate(fechaEstudio!),
      'numeroFdi': numeroFdi,
      'zona': zona,
      'diagnosticoRadiografico': diagnosticoRadiografico,
      'perdidaOseaObservada': perdidaOseaObservada,
      'tipoPerdidaOsea': tipoPerdidaOsea,
      'severidadPerdidaOsea': severidadPerdidaOsea,
      'porcentajePerdidaOseaEstimado': porcentajePerdidaOseaEstimado,
      'nivelCrestaOseaMm': nivelCrestaOseaMm,
      'observacionesPeriodontales': observacionesPeriodontales,
    };
  }

  Map<String, dynamic> toMultipartMap() {
    return toJson()..removeWhere((_, value) => value == null);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class RadiografiasService {
  const RadiografiasService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Radiografia>> listarPorFicha(int fichaId) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/fichas/$fichaId/radiografias',
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Radiografia.fromJson)
        .toList();
  }

  Future<Radiografia> crear({
    required int fichaId,
    required RadiografiaRequest request,
    required String filePath,
  }) async {
    final data = request.toMultipartMap();
    data['archivo'] = await MultipartFile.fromFile(filePath);
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/fichas/$fichaId/radiografias',
      data: FormData.fromMap(data),
    );
    return Radiografia.fromJson(response.data!);
  }

  Future<Radiografia> actualizar({
    required int radiografiaId,
    required RadiografiaRequest request,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/radiografias/$radiografiaId',
      data: request.toJson(),
    );
    return Radiografia.fromJson(response.data!);
  }

  Future<Radiografia> reemplazarImagen({
    required int radiografiaId,
    required String filePath,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/radiografias/$radiografiaId/imagen',
      data: FormData.fromMap({
        'archivo': await MultipartFile.fromFile(filePath),
      }),
    );
    return Radiografia.fromJson(response.data!);
  }

  Future<void> desactivar(int radiografiaId) async {
    await _apiClient.dio.delete<void>('/api/radiografias/$radiografiaId');
  }
}
