import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/models/servicio.dart';

class Cita {
  const Cita({
    required this.id,
    required this.paciente,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.motivo,
    required this.estado,
    this.usuarioRegistradorId,
    this.servicio,
    this.codigoGestion,
    this.notas,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] as int,
      paciente: Paciente.fromJson(json['paciente'] as Map<String, dynamic>),
      servicio: json['servicio'] == null
          ? null
          : Servicio.fromJson(json['servicio'] as Map<String, dynamic>),
      fechaHoraInicio: DateTime.parse(json['fechaHoraInicio'] as String),
      fechaHoraFin: DateTime.parse(json['fechaHoraFin'] as String),
      motivo: json['motivo'] as String,
      estado: json['estado'] as String,
      usuarioRegistradorId: json['usuarioRegistradorId'] as int?,
      codigoGestion: json['codigoGestion'] as String?,
      notas: json['notas'] as String?,
    );
  }

  final int id;
  final Paciente paciente;
  final Servicio? servicio;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final String motivo;
  final String estado;
  final int? usuarioRegistradorId;
  final String? codigoGestion;
  final String? notas;

  bool get registradaDesdeApp => usuarioRegistradorId != null;

  String get tituloServicio => servicio?.nombre ?? motivo;

  String get detalleServicio {
    final descripcion = servicio?.descripcion;
    if (descripcion != null && descripcion.isNotEmpty) {
      return descripcion;
    }
    return motivo;
  }

  String get hora {
    final hour = fechaHoraInicio.hour.toString().padLeft(2, '0');
    final minute = fechaHoraInicio.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
