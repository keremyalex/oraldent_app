import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/periodontograma.dart';

class PeriodontogramaDienteRequest {
  const PeriodontogramaDienteRequest({
    required this.ausente,
    required this.implante,
    required this.furcacionVestibular,
    required this.furcacionPalatinaLingual,
    this.movilidad,
    this.observacion,
  });

  final bool ausente;
  final bool implante;
  final int? movilidad;
  final String furcacionVestibular;
  final String furcacionPalatinaLingual;
  final String? observacion;

  Map<String, dynamic> toJson() {
    return {
      'ausente': ausente,
      'implante': implante,
      'movilidad': movilidad,
      'furcacionVestibular': furcacionVestibular,
      'furcacionPalatinaLingual': furcacionPalatinaLingual,
      'observacion': observacion,
    };
  }
}

class PeriodontogramaSitioRequest {
  const PeriodontogramaSitioRequest({
    required this.sangradoSondaje,
    required this.placa,
    required this.supuracion,
    required this.margenGingivalMm,
    required this.profundidadSondajeMm,
    this.observacion,
  });

  final bool sangradoSondaje;
  final bool placa;
  final bool supuracion;
  final int margenGingivalMm;
  final int profundidadSondajeMm;
  final String? observacion;

  Map<String, dynamic> toJson() {
    return {
      'sangradoSondaje': sangradoSondaje,
      'placa': placa,
      'supuracion': supuracion,
      'margenGingivalMm': margenGingivalMm,
      'profundidadSondajeMm': profundidadSondajeMm,
      'observacion': observacion,
    };
  }
}

class PeriodontogramaService {
  const PeriodontogramaService(this._apiClient);

  final ApiClient _apiClient;

  Future<Periodontograma> obtenerPorFicha(int fichaId) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/fichas/$fichaId/periodontograma',
    );
    return Periodontograma.fromJson(response.data!);
  }

  Future<Periodontograma> actualizarObservaciones({
    required int periodontogramaId,
    required String? observaciones,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/periodontogramas/$periodontogramaId/observaciones',
      data: {'observaciones': observaciones},
    );
    return Periodontograma.fromJson(response.data!);
  }

  Future<Periodontograma> actualizarDiente({
    required int periodontogramaId,
    required int numeroFdi,
    required PeriodontogramaDienteRequest request,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/periodontogramas/$periodontogramaId/dientes/$numeroFdi',
      data: request.toJson(),
    );
    return Periodontograma.fromJson(response.data!);
  }

  Future<Periodontograma> actualizarSitio({
    required int periodontogramaId,
    required int numeroFdi,
    required String sitio,
    required PeriodontogramaSitioRequest request,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/periodontogramas/$periodontogramaId/dientes/$numeroFdi/sitios/$sitio',
      data: request.toJson(),
    );
    return Periodontograma.fromJson(response.data!);
  }
}
