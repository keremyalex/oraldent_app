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
  int? _loadedPacienteId;
  List<FichaClinica> _fichas = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<FichaClinica> get fichas => _fichas;

  FichaClinica? fichaPorId(int fichaId) {
    for (final ficha in _fichas) {
      if (ficha.id == fichaId) {
        return ficha;
      }
    }
    return null;
  }

  Future<void> load(int pacienteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _fichas = _ordenarDesc(
        await _fichasService.listarPorPaciente(pacienteId),
      );
      _loadedPacienteId = pacienteId;
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadIfNeeded(int pacienteId) async {
    if (_loadedPacienteId == pacienteId || _isLoading) {
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
      _fichas = _ordenarDesc([ficha, ..._fichas]);
      _loadedPacienteId = pacienteId;
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
    final index = _fichas.indexWhere((item) => item.id == ficha.id);
    if (index == -1) {
      _fichas = [ficha, ..._fichas];
      return;
    }
    _fichas = [..._fichas.take(index), ficha, ..._fichas.skip(index + 1)];
    _fichas = _ordenarDesc(_fichas);
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
