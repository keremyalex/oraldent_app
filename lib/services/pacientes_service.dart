import 'package:dio/dio.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/paciente.dart';

class PacienteRequest {
  const PacienteRequest({
    required this.nombre,
    required this.apellidoPaterno,
    required this.celular,
    this.apellidoMaterno,
    this.documentoIdentidad,
    this.correo,
    this.fechaNacimiento,
    this.direccion,
    this.fotoUrl,
  });

  final String nombre;
  final String apellidoPaterno;
  final String celular;
  final String? apellidoMaterno;
  final String? documentoIdentidad;
  final String? correo;
  final DateTime? fechaNacimiento;
  final String? direccion;
  final String? fotoUrl;

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'celular': celular,
      'documentoIdentidad': documentoIdentidad,
      'correo': correo,
      'fechaNacimiento': fechaNacimiento == null
          ? null
          : _formatDate(fechaNacimiento!),
      'direccion': direccion,
      'fotoUrl': fotoUrl,
    };
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class PacientesService {
  const PacientesService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Paciente>> listar() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/api/pacientes');

    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Paciente.fromJson)
        .toList();
  }

  Future<Paciente> crear(PacienteRequest request) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/pacientes',
      data: request.toJson(),
    );
    return Paciente.fromJson(response.data!);
  }

  Future<Paciente> actualizar(int id, PacienteRequest request) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/pacientes/$id',
      data: request.toJson(),
    );
    return Paciente.fromJson(response.data!);
  }

  Future<Paciente> subirFoto({
    required int id,
    required String filePath,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/pacientes/$id/foto',
      data: FormData.fromMap({
        'archivo': await MultipartFile.fromFile(filePath),
      }),
    );
    return Paciente.fromJson(response.data!);
  }
}
