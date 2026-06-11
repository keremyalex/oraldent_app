class Radiografia {
  const Radiografia({
    required this.id,
    required this.fichaClinicaId,
    required this.titulo,
    required this.imagenUrl,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.descripcion,
    this.tipo,
    this.numeroFdi,
    this.zona,
    this.imagenPublicId,
    this.nombreArchivo,
    this.formato,
    this.tamanoBytes,
    this.anchoPx,
    this.altoPx,
    this.fechaEstudio,
    this.diagnosticoRadiografico,
    this.perdidaOseaObservada = false,
    this.tipoPerdidaOsea,
    this.severidadPerdidaOsea,
    this.porcentajePerdidaOseaEstimado,
    this.nivelCrestaOseaMm,
    this.observacionesPeriodontales,
  });

  factory Radiografia.fromJson(Map<String, dynamic> json) {
    return Radiografia(
      id: json['id'] as int,
      fichaClinicaId: json['fichaClinicaId'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      tipo: json['tipo'] as String?,
      numeroFdi: json['numeroFdi'] as int?,
      zona: json['zona'] as String?,
      imagenUrl: json['imagenUrl'] as String,
      imagenPublicId: json['imagenPublicId'] as String?,
      nombreArchivo: json['nombreArchivo'] as String?,
      formato: json['formato'] as String?,
      tamanoBytes: json['tamanoBytes'] as int?,
      anchoPx: json['anchoPx'] as int?,
      altoPx: json['altoPx'] as int?,
      fechaEstudio: json['fechaEstudio'] == null
          ? null
          : DateTime.parse(json['fechaEstudio'] as String),
      diagnosticoRadiografico: json['diagnosticoRadiografico'] as String?,
      perdidaOseaObservada: json['perdidaOseaObservada'] as bool? ?? false,
      tipoPerdidaOsea: json['tipoPerdidaOsea'] as String?,
      severidadPerdidaOsea: json['severidadPerdidaOsea'] as String?,
      porcentajePerdidaOseaEstimado:
          (json['porcentajePerdidaOseaEstimado'] as num?)?.toDouble(),
      nivelCrestaOseaMm: (json['nivelCrestaOseaMm'] as num?)?.toDouble(),
      observacionesPeriodontales: json['observacionesPeriodontales'] as String?,
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaActualizacion: DateTime.parse(json['fechaActualizacion'] as String),
    );
  }

  final int id;
  final int fichaClinicaId;
  final String titulo;
  final String? descripcion;
  final String? tipo;
  final int? numeroFdi;
  final String? zona;
  final String imagenUrl;
  final String? imagenPublicId;
  final String? nombreArchivo;
  final String? formato;
  final int? tamanoBytes;
  final int? anchoPx;
  final int? altoPx;
  final DateTime? fechaEstudio;
  final String? diagnosticoRadiografico;
  final bool perdidaOseaObservada;
  final String? tipoPerdidaOsea;
  final String? severidadPerdidaOsea;
  final double? porcentajePerdidaOseaEstimado;
  final double? nivelCrestaOseaMm;
  final String? observacionesPeriodontales;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  String get fechaEstudioFormateada {
    final date = fechaEstudio ?? fechaCreacion;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String get resumen {
    final values = [
      if (tipo?.isNotEmpty == true) tipo,
      if (numeroFdi != null) 'Pieza $numeroFdi',
      if (zona?.isNotEmpty == true) zona,
    ];
    return values.isEmpty ? 'Sin clasificar' : values.join(' · ');
  }
}
