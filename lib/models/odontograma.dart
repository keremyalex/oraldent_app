import 'package:flutter/material.dart';
import 'package:odontologia_app/models/paciente.dart';

class Odontograma {
  const Odontograma({
    required this.id,
    required this.paciente,
    required this.activo,
    required this.dientes,
    this.usuarioId,
    this.citaId,
    this.observaciones,
  });

  factory Odontograma.fromJson(Map<String, dynamic> json) {
    return Odontograma(
      id: json['id'] as int,
      paciente: Paciente.fromJson(json['paciente'] as Map<String, dynamic>),
      usuarioId: json['usuarioId'] as int?,
      citaId: json['citaId'] as int?,
      observaciones: json['observaciones'] as String?,
      activo: json['activo'] as bool? ?? true,
      dientes: (json['dientes'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(OdontogramaDiente.fromJson)
          .toList(),
    );
  }

  final int id;
  final Paciente paciente;
  final int? usuarioId;
  final int? citaId;
  final String? observaciones;
  final bool activo;
  final List<OdontogramaDiente> dientes;

  OdontogramaDiente? dientePorFdi(int numeroFdi) {
    for (final diente in dientes) {
      if (diente.numeroFdi == numeroFdi) {
        return diente;
      }
    }
    return null;
  }

  int get hallazgos {
    return dientes.where((diente) => diente.tieneHallazgos).length;
  }
}

class OdontogramaDiente {
  const OdontogramaDiente({
    required this.id,
    required this.numeroFdi,
    required this.cuadrante,
    required this.posicion,
    required this.ausente,
    required this.implante,
    required this.corona,
    required this.endodoncia,
    required this.extraccionIndicada,
    required this.caras,
    this.movilidad,
    this.observacion,
  });

  factory OdontogramaDiente.fromJson(Map<String, dynamic> json) {
    return OdontogramaDiente(
      id: json['id'] as int,
      numeroFdi: json['numeroFdi'] as int,
      cuadrante: json['cuadrante'] as int,
      posicion: json['posicion'] as int,
      ausente: json['ausente'] as bool? ?? false,
      implante: json['implante'] as bool? ?? false,
      corona: json['corona'] as bool? ?? false,
      endodoncia: json['endodoncia'] as bool? ?? false,
      extraccionIndicada: json['extraccionIndicada'] as bool? ?? false,
      movilidad: json['movilidad'] as int?,
      observacion: json['observacion'] as String?,
      caras: (json['caras'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(OdontogramaCara.fromJson)
          .toList(),
    );
  }

  final int id;
  final int numeroFdi;
  final int cuadrante;
  final int posicion;
  final bool ausente;
  final bool implante;
  final bool corona;
  final bool endodoncia;
  final bool extraccionIndicada;
  final int? movilidad;
  final String? observacion;
  final List<OdontogramaCara> caras;

  bool get tieneHallazgos {
    return ausente ||
        implante ||
        corona ||
        endodoncia ||
        extraccionIndicada ||
        movilidad != null ||
        (observacion != null && observacion!.isNotEmpty) ||
        caras.any((cara) => cara.color != OdontogramaColor.ninguno);
  }

  OdontogramaCara cara(String tipo) {
    return caras.firstWhere(
      (cara) => cara.tipo == tipo,
      orElse: () =>
          OdontogramaCara(id: 0, tipo: tipo, color: OdontogramaColor.ninguno),
    );
  }
}

class OdontogramaCara {
  const OdontogramaCara({
    required this.id,
    required this.tipo,
    required this.color,
    this.descripcion,
  });

  factory OdontogramaCara.fromJson(Map<String, dynamic> json) {
    return OdontogramaCara(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      color: json['color'] as String? ?? OdontogramaColor.ninguno,
      descripcion: json['descripcion'] as String?,
    );
  }

  final int id;
  final String tipo;
  final String color;
  final String? descripcion;
}

class OdontogramaColor {
  static const ninguno = 'NINGUNO';
  static const rojo = 'ROJO';
  static const azul = 'AZUL';

  static Color asColor(String value) {
    return switch (value) {
      rojo => const Color(0xFFDC2626),
      azul => const Color(0xFF2563EB),
      _ => Colors.white,
    };
  }

  static String next(String value) {
    return switch (value) {
      ninguno => rojo,
      rojo => azul,
      _ => ninguno,
    };
  }

  static String label(String value) {
    return switch (value) {
      rojo => 'Rojo',
      azul => 'Azul',
      _ => 'Sin marca',
    };
  }
}

class OdontogramaCaraTipo {
  static const oclusal = 'OCLUSAL';
  static const mesial = 'MESIAL';
  static const distal = 'DISTAL';
  static const vestibular = 'VESTIBULAR';
  static const palatino = 'PALATINO';

  static const all = [oclusal, mesial, distal, vestibular, palatino];

  static String label(String value) {
    return switch (value) {
      oclusal => 'Oclusal',
      mesial => 'Mesial',
      distal => 'Distal',
      vestibular => 'Vestibular',
      palatino => 'Palatino',
      _ => value,
    };
  }
}
