import 'dart:convert';
import 'dart:typed_data';

class AnalisisRadiografia {
  const AnalisisRadiografia({
    required this.id,
    required this.radiografiaId,
    required this.estado,
    required this.perdidaOseaDetectada,
    required this.validado,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.modelo,
    this.tipoPerdidaOsea,
    this.severidad,
    this.porcentajePerdidaOsea,
    this.confianza,
    this.resultadoJson,
    this.recomendacion,
    this.errorAnalisis,
    this.validadoPorUsuarioId,
    this.fechaValidacion,
    this.comentarioValidacion,
    this.severidadFinal,
    this.tipoPerdidaOseaFinal,
  });

  factory AnalisisRadiografia.fromJson(Map<String, dynamic> json) {
    return AnalisisRadiografia(
      id: json['id'] as int,
      radiografiaId: json['radiografiaId'] as int,
      modelo: json['modelo'] as String?,
      estado: json['estado'] as String? ?? 'PENDIENTE',
      perdidaOseaDetectada: json['perdidaOseaDetectada'] as bool? ?? false,
      tipoPerdidaOsea: json['tipoPerdidaOsea'] as String?,
      severidad: json['severidad'] as String?,
      porcentajePerdidaOsea: (json['porcentajePerdidaOsea'] as num?)
          ?.toDouble(),
      confianza: (json['confianza'] as num?)?.toDouble(),
      resultadoJson: json['resultadoJson'] as String?,
      recomendacion: json['recomendacion'] as String?,
      errorAnalisis: json['errorAnalisis'] as String?,
      validado: json['validado'] as bool? ?? false,
      validadoPorUsuarioId: json['validadoPorUsuarioId'] as int?,
      fechaValidacion: _parseDateTime(json['fechaValidacion']),
      comentarioValidacion: json['comentarioValidacion'] as String?,
      severidadFinal: json['severidadFinal'] as String?,
      tipoPerdidaOseaFinal: json['tipoPerdidaOseaFinal'] as String?,
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: _parseDateTime(json['fechaCreacion']) ?? DateTime.now(),
      fechaActualizacion:
          _parseDateTime(json['fechaActualizacion']) ?? DateTime.now(),
    );
  }

  final int id;
  final int radiografiaId;
  final String? modelo;
  final String estado;
  final bool perdidaOseaDetectada;
  final String? tipoPerdidaOsea;
  final String? severidad;
  final double? porcentajePerdidaOsea;
  final double? confianza;
  final String? resultadoJson;
  final String? recomendacion;
  final String? errorAnalisis;
  final bool validado;
  final int? validadoPorUsuarioId;
  final DateTime? fechaValidacion;
  final String? comentarioValidacion;
  final String? severidadFinal;
  final String? tipoPerdidaOseaFinal;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  bool get completado => estado == 'COMPLETADO';
  bool get tieneError => estado == 'ERROR' || errorAnalisis?.isNotEmpty == true;

  Uint8List? get overlayBytes {
    final rawResult = resultadoJson;
    if (rawResult == null || rawResult.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawResult);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final overlay = decoded['overlay'];
      if (overlay is! String || overlay.isEmpty) {
        return null;
      }
      final encoded = overlay.contains(',')
          ? overlay.substring(overlay.indexOf(',') + 1)
          : overlay;
      return base64Decode(encoded);
    } on FormatException {
      return null;
    }
  }
}

DateTime? _parseDateTime(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
