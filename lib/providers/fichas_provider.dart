import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/ficha_clinica.dart';
import 'package:odontologia_app/services/fichas_service.dart';

class FichasProvider extends ChangeNotifier {
  FichasProvider(this._fichasService);

  final FichasService _fichasService;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  final Map<int, List<FichaClinica>> _fichasPorPaciente = {};
  final Set<int> _pacientesCargando = {};
  final Map<int, String> _erroresPorPaciente = {};

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<FichaClinica> fichasDePaciente(int pacienteId) {
    return _fichasPorPaciente[pacienteId] ?? const [];
  }

  bool cargandoPaciente(int pacienteId) {
    return _pacientesCargando.contains(pacienteId);
  }

  String? errorDePaciente(int pacienteId) {
    return _erroresPorPaciente[pacienteId];
  }

  FichaClinica? fichaPorId(int fichaId) {
    for (final fichas in _fichasPorPaciente.values) {
      for (final ficha in fichas) {
        if (ficha.id == fichaId) {
          return ficha;
        }
      }
    }
    return null;
  }

  Future<void> load(int pacienteId) async {
    _pacientesCargando.add(pacienteId);
    _erroresPorPaciente.remove(pacienteId);
    notifyListeners();

    try {
      _fichasPorPaciente[pacienteId] = _ordenarDesc(
        await _fichasService.listarPorPaciente(pacienteId),
      );
    } catch (error) {
      _erroresPorPaciente[pacienteId] = apiErrorMessage(error);
    } finally {
      _pacientesCargando.remove(pacienteId);
      notifyListeners();
    }
  }

  Future<void> loadIfNeeded(int pacienteId) async {
    if (_fichasPorPaciente.containsKey(pacienteId) ||
        _pacientesCargando.contains(pacienteId)) {
      return;
    }
    await load(pacienteId);
  }

  Future<String?> crearFichaInicial(int pacienteId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ficha = await _fichasService.crear(
        pacienteId: pacienteId,
        request: FichaClinicaRequest(fecha: DateTime.now()),
      );
      _fichasPorPaciente[pacienteId] = _ordenarDesc([
        ficha,
        ...fichasDePaciente(pacienteId),
      ]);
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<FichaClinica?> obtenerFicha(int fichaId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ficha = await _fichasService.obtener(fichaId);
      _replaceFicha(ficha);
      return ficha;
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> actualizarFicha({
    required int fichaId,
    required FichaClinicaRequest request,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ficha = await _fichasService.actualizar(
        fichaId: fichaId,
        request: request,
      );
      _replaceFicha(ficha);
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _replaceFicha(FichaClinica ficha) {
    final pacienteId = ficha.paciente.id;
    final fichas = fichasDePaciente(pacienteId);
    final index = fichas.indexWhere((item) => item.id == ficha.id);
    if (index == -1) {
      _fichasPorPaciente[pacienteId] = _ordenarDesc([ficha, ...fichas]);
      return;
    }
    _fichasPorPaciente[pacienteId] = _ordenarDesc([
      ...fichas.take(index),
      ficha,
      ...fichas.skip(index + 1),
    ]);
  }

  List<FichaClinica> _ordenarDesc(List<FichaClinica> fichas) {
    return [...fichas]..sort((a, b) {
      final fechaCompare = b.fecha.compareTo(a.fecha);
      if (fechaCompare != 0) {
        return fechaCompare;
      }
      return b.id.compareTo(a.id);
    });
  }
}
