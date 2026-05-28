import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/periodontograma.dart';
import 'package:odontologia_app/services/periodontograma_service.dart';

class PeriodontogramaProvider extends ChangeNotifier {
  PeriodontogramaProvider(this._service);

  final PeriodontogramaService _service;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Periodontograma? _periodontograma;
  int? _currentFichaId;
  int _requestVersion = 0;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  Periodontograma? get periodontograma => _periodontograma;

  Future<void> loadPorFicha(int fichaId) async {
    final requestVersion = ++_requestVersion;
    final isDifferentFicha = _currentFichaId != fichaId;

    _isLoading = true;
    _errorMessage = null;
    _currentFichaId = fichaId;
    if (isDifferentFicha) {
      _periodontograma = null;
    }
    notifyListeners();

    try {
      final periodontograma = await _service.obtenerPorFicha(fichaId);
      if (requestVersion != _requestVersion) {
        return;
      }
      _periodontograma = periodontograma;
    } catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _errorMessage = apiErrorMessage(error);
      _periodontograma = null;
    } finally {
      if (requestVersion == _requestVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<String?> actualizarObservaciones(String value) async {
    final current = _periodontograma;
    if (current == null) {
      return 'No hay periodontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();
    try {
      _periodontograma = await _service.actualizarObservaciones(
        periodontogramaId: current.id,
        observaciones: value.trim().isEmpty ? null : value.trim(),
      );
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> actualizarDiente({
    required PeriodontogramaDiente diente,
    required PeriodontogramaDienteRequest request,
  }) async {
    final current = _periodontograma;
    if (current == null) {
      return 'No hay periodontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();
    try {
      _periodontograma = await _service.actualizarDiente(
        periodontogramaId: current.id,
        numeroFdi: diente.numeroFdi,
        request: request,
      );
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> actualizarSitio({
    required PeriodontogramaDiente diente,
    required PeriodontogramaSitio sitio,
    required PeriodontogramaSitioRequest request,
  }) async {
    final current = _periodontograma;
    if (current == null) {
      return 'No hay periodontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();
    try {
      _periodontograma = await _service.actualizarSitio(
        periodontogramaId: current.id,
        numeroFdi: diente.numeroFdi,
        sitio: sitio.sitio,
        request: request,
      );
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
