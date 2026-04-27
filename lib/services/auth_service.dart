import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/auth_session.dart';
import 'package:odontologia_app/models/usuario_auth.dart';
import 'package:odontologia_app/services/session_storage.dart';

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

  Future<void> logout() async {
    _apiClient.setAuthToken(null);
    await _sessionStorage.clearSession();
  }
}
