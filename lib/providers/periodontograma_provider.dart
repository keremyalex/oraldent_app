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

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  Periodontograma? get periodontograma => _periodontograma;

  Future<void> load(int pacienteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _periodontograma = await _service.obtenerPorPaciente(pacienteId);
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
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
