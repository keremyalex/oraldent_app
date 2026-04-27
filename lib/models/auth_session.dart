import 'package:odontologia_app/models/usuario_auth.dart';

class AuthSession {
  const AuthSession({
    required this.token,
    required this.tipoToken,
    required this.usuario,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      tipoToken: json['tipoToken'] as String,
      usuario: UsuarioAuth.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'tipoToken': tipoToken,
      'usuario': usuario.toJson(),
    };
  }

  final String token;
  final String tipoToken;
  final UsuarioAuth usuario;
}
