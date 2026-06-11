class Receta {
  const Receta({
    required this.id,
    required this.fichaClinicaId,
    required this.activo,
    required this.detalles,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.usuarioId,
    this.indicacionesGenerales,
    this.observaciones,
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    return Receta(
      id: json['id'] as int,
      fichaClinicaId: json['fichaClinicaId'] as int,
      usuarioId: json['usuarioId'] as int?,
      indicacionesGenerales: json['indicacionesGenerales'] as String?,
      observaciones: json['observaciones'] as String?,
      activo: json['activo'] as bool? ?? true,
      detalles: ((json['detalles'] as List<dynamic>?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(RecetaDetalle.fromJson)
          .toList(),
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaActualizacion: DateTime.parse(json['fechaActualizacion'] as String),
    );
  }

  final int id;
  final int fichaClinicaId;
  final int? usuarioId;
  final String? indicacionesGenerales;
  final String? observaciones;
  final bool activo;
  final List<RecetaDetalle> detalles;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  String get titulo {
    if (detalles.isEmpty) {
      return 'Receta #$id';
    }
    return detalles.first.medicamento;
  }

  String get fechaFormateada {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(fechaCreacion.day)}/${two(fechaCreacion.month)}/${fechaCreacion.year}';
  }
}

class RecetaDetalle {
  const RecetaDetalle({
    required this.id,
    required this.medicamento,
    this.dosis,
    this.frecuencia,
    this.duracion,
    this.indicaciones,
    this.orden = 0,
  });

  factory RecetaDetalle.fromJson(Map<String, dynamic> json) {
    return RecetaDetalle(
      id: json['id'] as int?,
      medicamento: json['medicamento'] as String? ?? 'Medicamento',
      dosis: json['dosis'] as String?,
      frecuencia: json['frecuencia'] as String?,
      duracion: json['duracion'] as String?,
      indicaciones: json['indicaciones'] as String?,
      orden: json['orden'] as int? ?? 0,
    );
  }

  final int? id;
  final String medicamento;
  final String? dosis;
  final String? frecuencia;
  final String? duracion;
  final String? indicaciones;
  final int orden;
}
