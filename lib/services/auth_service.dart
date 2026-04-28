import 'package:dio/dio.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/auth_session.dart';
import 'package:odontologia_app/models/usuario_auth.dart';
import 'package:odontologia_app/services/session_storage.dart';

class PerfilUsuarioRequest {
  const PerfilUsuarioRequest({
    required this.nombre,
    required this.apellidoPaterno,
    required this.correo,
    required this.celular,
    this.apellidoMaterno,
  });

  final String nombre;
  final String apellidoPaterno;
  final String? apellidoMaterno;
  final String correo;
  final String celular;

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'correo': correo,
      'celular': celular,
    };
  }
}

class AuthService {
  const AuthService(
    this._apiClient,
    this._sessionStorage,
  );

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Future<AuthSession> login({
    required String identificador,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {
        'identificador': identificador,
        'password': password,
      },
    );

    final session = AuthSession.fromJson(response.data!);
    _apiClient.setAuthToken(session.token);
    await _sessionStorage.saveSession(session);
    return session;
  }

  Future<AuthSession?> restoreSession() async {
    final storedSession = await _sessionStorage.readSession();
    if (storedSession == null) {
      return null;
    }

    _apiClient.setAuthToken(storedSession.token);

    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/auth/me',
      );
      final user = UsuarioAuth.fromJson(response.data!);
      final session = AuthSession(
        token: storedSession.token,
        tipoToken: storedSession.tipoToken,
        usuario: user,
      );
      await _sessionStorage.saveSession(session);
      return session;
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<UsuarioAuth> subirFotoPerfil(String filePath) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/auth/me/foto-perfil',
      data: FormData.fromMap({
        'archivo': await MultipartFile.fromFile(filePath),
      }),
    );
    return UsuarioAuth.fromJson(response.data!);
  }

  Future<AuthSession> actualizarPerfil(PerfilUsuarioRequest request) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/auth/me',
      data: request.toJson(),
    );

    final session = AuthSession.fromJson(response.data!);
    _apiClient.setAuthToken(session.token);
    await _sessionStorage.saveSession(session);
    return session;
  }

  Future<void> saveSession(AuthSession session) {
    return _sessionStorage.saveSession(session);
  }

  Future<void> logout() async {
    _apiClient.setAuthToken(null);
    await _sessionStorage.clearSession();
  }
}
