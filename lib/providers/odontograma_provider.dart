import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/odontograma.dart';
import 'package:odontologia_app/services/odontograma_service.dart';

class OdontogramaProvider extends ChangeNotifier {
  OdontogramaProvider(this._odontogramaService);

  final OdontogramaService _odontogramaService;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Odontograma? _odontograma;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  Odontograma? get odontograma => _odontograma;

  Future<void> load(int pacienteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _odontograma = await _odontogramaService.obtenerPorPaciente(pacienteId);
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> actualizarDiente({
    required OdontogramaDiente diente,
    required OdontogramaDienteRequest request,
  }) async {
    final current = _odontograma;
    if (current == null) {
      return 'No hay odontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();

    try {
      _odontograma = await _odontogramaService.actualizarDiente(
        odontogramaId: current.id,
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

  Future<String?> alternarCara({
    required OdontogramaDiente diente,
    required OdontogramaCara cara,
  }) async {
    final current = _odontograma;
    if (current == null) {
      return 'No hay odontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();

    try {
      _odontograma = await _odontogramaService.actualizarCara(
        odontogramaId: current.id,
        numeroFdi: diente.numeroFdi,
        tipo: cara.tipo,
        color: OdontogramaColor.next(cara.color),
        descripcion: cara.descripcion,
      );
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> actualizarObservaciones(String value) async {
    final current = _odontograma;
    if (current == null) {
      return 'No hay odontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();

    try {
      _odontograma = await _odontogramaService.actualizarObservaciones(
        odontogramaId: current.id,
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
}
