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
  bool _hasLoaded = false;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  List<Paciente> get pacientes => _pacientes;
  bool get hasLoaded => _hasLoaded;

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
      _hasLoaded = true;
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadIfNeeded() async {
    if (_hasLoaded || _isLoading) {
      return;
    }
    await load();
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<String?> save({
    int? id,
    required PacienteRequest request,
  }) async {
    final result = await savePaciente(id: id, request: request);
    return result.errorMessage;
  }

  Future<PacienteSaveResult> savePaciente({
    int? id,
    required PacienteRequest request,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final Paciente paciente;
      if (id == null) {
        paciente = await _pacientesService.crear(request);
      } else {
        paciente = await _pacientesService.actualizar(id, request);
      }
      await load();
      return PacienteSaveResult(paciente: paciente);
    } catch (error) {
      return PacienteSaveResult(errorMessage: apiErrorMessage(error));
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> uploadPhoto({
    required int id,
    required String filePath,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final paciente = await _pacientesService.subirFoto(
        id: id,
        filePath: filePath,
      );
      _replacePaciente(paciente);
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _replacePaciente(Paciente paciente) {
    final index = _pacientes.indexWhere((item) => item.id == paciente.id);
    if (index == -1) {
      _pacientes = [..._pacientes, paciente];
      return;
    }
    _pacientes = [
      ..._pacientes.take(index),
      paciente,
      ..._pacientes.skip(index + 1),
    ];
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

class PacienteSaveResult {
  const PacienteSaveResult({
    this.paciente,
    this.errorMessage,
  });

  final Paciente? paciente;
  final String? errorMessage;
}
