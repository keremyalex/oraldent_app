import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:odontologia_app/models/auth_session.dart';

class SessionStorage {
  const SessionStorage(this._storage);

  static const _sessionKey = 'auth_session';

  final FlutterSecureStorage _storage;

  Future<void> saveSession(AuthSession session) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<AuthSession?> readSession() async {
    final rawSession = await _storage.read(key: _sessionKey);
    if (rawSession == null || rawSession.isEmpty) {
      return null;
    }

    return AuthSession.fromJson(
      jsonDecode(rawSession) as Map<String, dynamic>,
    );
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }
}
