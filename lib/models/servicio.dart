class Servicio {
  const Servicio({
    required this.id,
    required this.nombre,
    required this.activo,
    this.descripcion,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  final int id;
  final String nombre;
  final String? descripcion;
  final bool activo;
}
