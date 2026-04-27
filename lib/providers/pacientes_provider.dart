import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/services/pacientes_service.dart';

class PacientesProvider extends ChangeNotifier {
  PacientesProvider(this._pacientesService);

  final PacientesService _pacientesService;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _query = '';
  List<Paciente> _pacientes = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  List<Paciente> get pacientes => _pacientes;

  List<Paciente> get filteredPacientes {
    final normalizedQuery = _normalize(_query);
    if (normalizedQuery.isEmpty) {
      return _pacientes;
    }

    return _pacientes.where((paciente) {
      final searchable = _normalize(
        [
          paciente.nombreCompleto,
          paciente.celular,
          paciente.documentoIdentidad ?? '',
          paciente.correo ?? '',
        ].join(' '),
      );
      return searchable.contains(normalizedQuery);
    }).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pacientes = await _pacientesService.listar();
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<String?> save({
    int? id,
    required PacienteRequest request,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      if (id == null) {
        await _pacientesService.crear(request);
      } else {
        await _pacientesService.actualizar(id, request);
      }
      await load();
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }
}
