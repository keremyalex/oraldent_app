import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/auth_session.dart';
import 'package:odontologia_app/models/usuario_auth.dart';
import 'package:odontologia_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  AuthSession? _session;
  bool _isLoading = false;
  bool _isRestoring = true;
  String? _errorMessage;

  AuthSession? get session => _session;
  UsuarioAuth? get usuario => _session?.usuario;
  bool get isLoading => _isLoading;
  bool get isRestoring => _isRestoring;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _session != null;

  Future<void> restoreSession() async {
    _isRestoring = true;
    notifyListeners();

    try {
      _session = await _authService.restoreSession();
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String identificador,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _authService.login(
        identificador: identificador,
        password: password,
      );
      return true;
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _session = null;
    notifyListeners();
  }
}
