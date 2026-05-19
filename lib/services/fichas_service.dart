import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/ficha_clinica.dart';

class FichaClinicaRequest {
  const FichaClinicaRequest({
    this.citaId,
    this.fecha,
    this.edad,
    this.sexo,
    this.procedencia,
    this.ocupacion,
    this.presionArterial,
    this.temperatura,
    this.pulso,
    this.motivoConsulta,
    this.enfermedadActual,
    this.anamnesis,
    this.hemorragia,
    this.diabetes,
    this.hipertension,
    this.epilepsia,
    this.problemasCardiovasculares,
    this.lipotimias,
    this.tratamientoMedicoActual,
    this.alergias,
    this.medicamentoActual,
    this.otrasPatologias,
    this.examenClinico,
    this.examenRadiografico,
    this.diagnostico,
    this.tratamiento,
    this.tecnicaAnestesia,
    this.evolucion,
  });

  final int? citaId;
  final DateTime? fecha;
  final int? edad;
  final String? sexo;
  final String? procedencia;
  final String? ocupacion;
  final String? presionArterial;
  final double? temperatura;
  final int? pulso;
  final String? motivoConsulta;
  final String? enfermedadActual;
  final String? anamnesis;
  final bool? hemorragia;
  final bool? diabetes;
  final bool? hipertension;
  final bool? epilepsia;
  final bool? problemasCardiovasculares;
  final bool? lipotimias;
  final bool? tratamientoMedicoActual;
  final String? alergias;
  final String? medicamentoActual;
  final String? otrasPatologias;
  final String? examenClinico;
  final String? examenRadiografico;
  final String? diagnostico;
  final String? tratamiento;
  final String? tecnicaAnestesia;
  final String? evolucion;

  Map<String, dynamic> toJson() {
    return {
      'citaId': citaId,
      'fecha': fecha?.toIso8601String(),
      'edad': edad,
      'sexo': sexo,
      'procedencia': procedencia,
      'ocupacion': ocupacion,
      'presionArterial': presionArterial,
      'temperatura': temperatura,
      'pulso': pulso,
      'motivoConsulta': motivoConsulta,
      'enfermedadActual': enfermedadActual,
      'anamnesis': anamnesis,
      'hemorragia': hemorragia,
      'diabetes': diabetes,
      'hipertension': hipertension,
      'epilepsia': epilepsia,
      'problemasCardiovasculares': problemasCardiovasculares,
      'lipotimias': lipotimias,
      'tratamientoMedicoActual': tratamientoMedicoActual,
      'alergias': alergias,
      'medicamentoActual': medicamentoActual,
      'otrasPatologias': otrasPatologias,
      'examenClinico': examenClinico,
      'examenRadiografico': examenRadiografico,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'tecnicaAnestesia': tecnicaAnestesia,
      'evolucion': evolucion,
    };
  }
}

class FichasService {
  const FichasService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<FichaClinica>> listarPorPaciente(int pacienteId) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/pacientes/$pacienteId/fichas',
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(FichaClinica.fromJson)
        .toList();
  }

  Future<FichaClinica> crear({
    required int pacienteId,
    required FichaClinicaRequest request,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/pacientes/$pacienteId/fichas',
      data: request.toJson(),
    );
    return FichaClinica.fromJson(response.data!);
  }

  Future<FichaClinica> obtener(int fichaId) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/fichas/$fichaId',
    );
    return FichaClinica.fromJson(response.data!);
  }

  Future<FichaClinica> actualizar({
    required int fichaId,
    required FichaClinicaRequest request,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/fichas/$fichaId',
      data: request.toJson(),
    );
    return FichaClinica.fromJson(response.data!);
  }
}
