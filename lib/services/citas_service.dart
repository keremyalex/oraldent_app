import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/cita.dart';

class CitaRequest {
  const CitaRequest({
    required this.pacienteId,
    required this.servicioId,
    required this.fechaHoraInicio,
    required this.motivo,
    this.notas,
  });

  final int pacienteId;
  final int servicioId;
  final DateTime fechaHoraInicio;
  final String motivo;
  final String? notas;

  Map<String, dynamic> toJson() {
    return {
      'pacienteId': pacienteId,
      'servicioId': servicioId,
      'fechaHoraInicio': _formatDateTime(fechaHoraInicio),
      'motivo': motivo,
      'notas': notas,
    };
  }
}

class CitasService {
  const CitasService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Cita>> listarPorFecha(DateTime fecha) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/citas',
      queryParameters: {'fecha': _formatDate(fecha)},
    );

    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Cita.fromJson)
        .toList();
  }

  Future<List<String>> disponibilidad(DateTime fecha) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/citas/disponibilidad',
      queryParameters: {'fecha': _formatDate(fecha)},
    );

    return (response.data!['horariosDisponibles'] as List<dynamic>)
        .cast<String>();
  }

  Future<Cita> crear(CitaRequest request) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/citas',
      data: request.toJson(),
    );
    return Cita.fromJson(response.data!);
  }

  Future<Cita> reprogramar({
    required int id,
    required String codigoGestion,
    required DateTime nuevaFechaHoraInicio,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/citas/$id/reprogramar',
      queryParameters: {'codigoGestion': codigoGestion},
      data: {'nuevaFechaHoraInicio': _formatDateTime(nuevaFechaHoraInicio)},
    );
    return Cita.fromJson(response.data!);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

String _formatDateTime(DateTime dateTime) {
  final date = [
    dateTime.year.toString().padLeft(4, '0'),
    dateTime.month.toString().padLeft(2, '0'),
    dateTime.day.toString().padLeft(2, '0'),
  ].join('-');
  final time = [
    dateTime.hour.toString().padLeft(2, '0'),
    dateTime.minute.toString().padLeft(2, '0'),
    '00',
  ].join(':');
  return '${date}T$time';
}
