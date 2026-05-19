import 'package:odontologia_app/models/paciente.dart';

class FichaClinica {
  const FichaClinica({
    required this.id,
    required this.paciente,
    required this.fecha,
    required this.activo,
    this.usuarioId,
    this.citaId,
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
    this.hemorragia = false,
    this.diabetes = false,
    this.hipertension = false,
    this.epilepsia = false,
    this.problemasCardiovasculares = false,
    this.lipotimias = false,
    this.tratamientoMedicoActual = false,
    this.alergias,
    this.medicamentoActual,
    this.otrasPatologias,
    this.examenClinico,
    this.examenRadiografico,
    this.diagnostico,
    this.tratamiento,
    this.tecnicaAnestesia,
    this.evolucion,
    this.odontogramaId,
    this.periodontogramaId,
  });

  factory FichaClinica.fromJson(Map<String, dynamic> json) {
    return FichaClinica(
      id: json['id'] as int,
      paciente: Paciente.fromJson(json['paciente'] as Map<String, dynamic>),
      usuarioId: json['usuarioId'] as int?,
      citaId: json['citaId'] as int?,
      fecha: DateTime.parse(json['fecha'] as String),
      edad: json['edad'] as int?,
      sexo: json['sexo'] as String?,
      procedencia: json['procedencia'] as String?,
      ocupacion: json['ocupacion'] as String?,
      presionArterial: json['presionArterial'] as String?,
      temperatura: (json['temperatura'] as num?)?.toDouble(),
      pulso: json['pulso'] as int?,
      motivoConsulta: json['motivoConsulta'] as String?,
      enfermedadActual: json['enfermedadActual'] as String?,
      anamnesis: json['anamnesis'] as String?,
      hemorragia: json['hemorragia'] as bool? ?? false,
      diabetes: json['diabetes'] as bool? ?? false,
      hipertension: json['hipertension'] as bool? ?? false,
      epilepsia: json['epilepsia'] as bool? ?? false,
      problemasCardiovasculares:
          json['problemasCardiovasculares'] as bool? ?? false,
      lipotimias: json['lipotimias'] as bool? ?? false,
      tratamientoMedicoActual:
          json['tratamientoMedicoActual'] as bool? ?? false,
      alergias: json['alergias'] as String?,
      medicamentoActual: json['medicamentoActual'] as String?,
      otrasPatologias: json['otrasPatologias'] as String?,
      examenClinico: json['examenClinico'] as String?,
      examenRadiografico: json['examenRadiografico'] as String?,
      diagnostico: json['diagnostico'] as String?,
      tratamiento: json['tratamiento'] as String?,
      tecnicaAnestesia: json['tecnicaAnestesia'] as String?,
      evolucion: json['evolucion'] as String?,
      activo: json['activo'] as bool? ?? true,
      odontogramaId: json['odontogramaId'] as int?,
      periodontogramaId: json['periodontogramaId'] as int?,
    );
  }

  final int id;
  final Paciente paciente;
  final int? usuarioId;
  final int? citaId;
  final DateTime fecha;
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
  final bool hemorragia;
  final bool diabetes;
  final bool hipertension;
  final bool epilepsia;
  final bool problemasCardiovasculares;
  final bool lipotimias;
  final bool tratamientoMedicoActual;
  final String? alergias;
  final String? medicamentoActual;
  final String? otrasPatologias;
  final String? examenClinico;
  final String? examenRadiografico;
  final String? diagnostico;
  final String? tratamiento;
  final String? tecnicaAnestesia;
  final String? evolucion;
  final bool activo;
  final int? odontogramaId;
  final int? periodontogramaId;

  String get fechaFormateada {
    final day = fecha.day.toString().padLeft(2, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    return '$day/$month/${fecha.year}';
  }

  String get titulo => 'Ficha N° $id';

  bool get tieneDatosClinicos {
    return [
      motivoConsulta,
      enfermedadActual,
      anamnesis,
      alergias,
      medicamentoActual,
      otrasPatologias,
      examenClinico,
      examenRadiografico,
      diagnostico,
      tratamiento,
      tecnicaAnestesia,
      evolucion,
    ].any((value) => value != null && value.trim().isNotEmpty);
  }
}
