import 'package:flutter/material.dart';

class HorarioAtencion {
  const HorarioAtencion({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.duracionCitaMinutos,
    required this.activo,
    this.observacion,
  });

  factory HorarioAtencion.fromJson(Map<String, dynamic> json) {
    return HorarioAtencion(
      id: json['id'] as int,
      diaSemana: json['diaSemana'] as String,
      horaInicio: _parseTime(json['horaInicio'] as String),
      horaFin: _parseTime(json['horaFin'] as String),
      duracionCitaMinutos: json['duracionCitaMinutos'] as int,
      observacion: json['observacion'] as String?,
      activo: json['activo'] as bool,
    );
  }

  final int id;
  final String diaSemana;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;
  final int duracionCitaMinutos;
  final String? observacion;
  final bool activo;

  String get diaLabel {
    return switch (diaSemana) {
      'LUNES' => 'Lunes',
      'MARTES' => 'Martes',
      'MIERCOLES' => 'Miercoles',
      'JUEVES' => 'Jueves',
      'VIERNES' => 'Viernes',
      'SABADO' => 'Sabado',
      'DOMINGO' => 'Domingo',
      'MONDAY' => 'Lunes',
      'TUESDAY' => 'Martes',
      'WEDNESDAY' => 'Miercoles',
      'THURSDAY' => 'Jueves',
      'FRIDAY' => 'Viernes',
      'SATURDAY' => 'Sabado',
      'SUNDAY' => 'Domingo',
      _ => diaSemana,
    };
  }

  String get rango => '${formatTime(horaInicio)} - ${formatTime(horaFin)}';

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
