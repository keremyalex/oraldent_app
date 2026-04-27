class UsuarioAuth {
  const UsuarioAuth({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.celular,
    required this.rol,
    this.apellidoMaterno,
    this.correo,
    this.fotoPerfilUrl,
    this.pacienteId,
  });

  factory UsuarioAuth.fromJson(Map<String, dynamic> json) {
    return UsuarioAuth(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellidoPaterno: json['apellidoPaterno'] as String,
      apellidoMaterno: json['apellidoMaterno'] as String?,
      correo: json['correo'] as String?,
      celular: json['celular'] as String,
      rol: json['rol'] as String,
      fotoPerfilUrl: json['fotoPerfilUrl'] as String?,
      pacienteId: json['pacienteId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'correo': correo,
      'celular': celular,
      'rol': rol,
      'fotoPerfilUrl': fotoPerfilUrl,
      'pacienteId': pacienteId,
    };
  }

  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String? correo;
  final String celular;
  final String rol;
  final String? fotoPerfilUrl;
  final int? pacienteId;

  String get nombreCompleto {
    final materno = apellidoMaterno;
    return [
      nombre,
      apellidoPaterno,
      if (materno != null && materno.isNotEmpty) materno,
    ].join(' ');
  }
}
