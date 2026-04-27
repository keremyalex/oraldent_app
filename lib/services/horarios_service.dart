import 'package:flutter/material.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/horario_atencion.dart';

class HorarioRequest {
  const HorarioRequest({
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.duracionCitaMinutos,
    this.observacion,
  });

  final String diaSemana;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;
  final int duracionCitaMinutos;
  final String? observacion;

  Map<String, dynamic> toJson() {
    return {
      'diaSemana': diaSemana,
      'horaInicio': HorarioAtencion.formatTime(horaInicio),
      'horaFin': HorarioAtencion.formatTime(horaFin),
      'duracionCitaMinutos': duracionCitaMinutos,
      'observacion': observacion,
    };
  }
}

class HorariosService {
  const HorariosService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<HorarioAtencion>> listar() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/api/horarios');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(HorarioAtencion.fromJson)
        .toList();
  }

  Future<HorarioAtencion> crear(HorarioRequest request) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/horarios',
      data: request.toJson(),
    );
    return HorarioAtencion.fromJson(response.data!);
  }

  Future<HorarioAtencion> actualizar(int id, HorarioRequest request) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/horarios/$id',
      data: request.toJson(),
    );
    return HorarioAtencion.fromJson(response.data!);
  }

  Future<void> desactivar(int id) async {
    await _apiClient.dio.delete<void>('/api/horarios/$id');
  }
}
