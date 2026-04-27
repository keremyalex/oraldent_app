class Paciente {
  const Paciente({
    required this.id,
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

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellidoPaterno: json['apellidoPaterno'] as String,
      apellidoMaterno: json['apellidoMaterno'] as String?,
      celular: json['celular'] as String,
      documentoIdentidad: json['documentoIdentidad'] as String?,
      correo: json['correo'] as String?,
      fechaNacimiento: json['fechaNacimiento'] == null
          ? null
          : DateTime.parse(json['fechaNacimiento'] as String),
      direccion: json['direccion'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
    );
  }

  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String celular;
  final String? documentoIdentidad;
  final String? correo;
  final DateTime? fechaNacimiento;
  final String? direccion;
  final String? fotoUrl;

  String get nombreCompleto {
    final materno = apellidoMaterno;
    return [
      nombre,
      apellidoPaterno,
      if (materno != null && materno.isNotEmpty) materno,
    ].join(' ');
  }

  String get initials {
    final first = nombre.isNotEmpty ? nombre[0] : '';
    final last = apellidoPaterno.isNotEmpty ? apellidoPaterno[0] : '';
    return '$first$last'.toUpperCase();
  }
}
