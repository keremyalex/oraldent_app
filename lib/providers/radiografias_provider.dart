import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/radiografia.dart';
import 'package:odontologia_app/services/radiografias_service.dart';

class RadiografiasProvider extends ChangeNotifier {
  RadiografiasProvider(this._service);

  final RadiografiasService _service;

  final Map<int, List<Radiografia>> _radiografiasPorFicha = {};
  final Set<int> _fichasCargando = {};
  final Map<int, String> _erroresPorFicha = {};
  bool _isSaving = false;

  bool get isSaving => _isSaving;

  List<Radiografia> radiografiasDeFicha(int fichaId) {
    return _radiografiasPorFicha[fichaId] ?? const [];
  }

  bool cargandoFicha(int fichaId) {
    return _fichasCargando.contains(fichaId);
  }

  String? errorDeFicha(int fichaId) {
    return _erroresPorFicha[fichaId];
  }

  Future<void> load(int fichaId) async {
    _fichasCargando.add(fichaId);
    _erroresPorFicha.remove(fichaId);
    notifyListeners();

    try {
      _radiografiasPorFicha[fichaId] = await _service.listarPorFicha(fichaId);
    } catch (error) {
      _erroresPorFicha[fichaId] = apiErrorMessage(error);
    } finally {
      _fichasCargando.remove(fichaId);
      notifyListeners();
    }
  }

  Future<void> loadIfNeeded(int fichaId) async {
    if (_radiografiasPorFicha.containsKey(fichaId) ||
        _fichasCargando.contains(fichaId)) {
      return;
    }
    await load(fichaId);
  }

  Future<String?> crear({
    required int fichaId,
    required RadiografiaRequest request,
    required String filePath,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final radiografia = await _service.crear(
        fichaId: fichaId,
        request: request,
        filePath: filePath,
      );
      _radiografiasPorFicha[fichaId] = [
        radiografia,
        ...radiografiasDeFicha(fichaId),
      ];
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> actualizar({
    required Radiografia radiografia,
    required RadiografiaRequest request,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final updated = await _service.actualizar(
        radiografiaId: radiografia.id,
        request: request,
      );
      _replace(updated);
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> reemplazarImagen({
    required Radiografia radiografia,
    required String filePath,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final updated = await _service.reemplazarImagen(
        radiografiaId: radiografia.id,
        filePath: filePath,
      );
      _replace(updated);
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> desactivar(Radiografia radiografia) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _service.desactivar(radiografia.id);
      _radiografiasPorFicha[radiografia.fichaClinicaId] = radiografiasDeFicha(
        radiografia.fichaClinicaId,
      ).where((item) => item.id != radiografia.id).toList();
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _replace(Radiografia radiografia) {
    final current = radiografiasDeFicha(radiografia.fichaClinicaId);
    final index = current.indexWhere((item) => item.id == radiografia.id);
    if (index == -1) {
      _radiografiasPorFicha[radiografia.fichaClinicaId] = [
        radiografia,
        ...current,
      ];
      return;
    }
    _radiografiasPorFicha[radiografia.fichaClinicaId] = [
      ...current.take(index),
      radiografia,
      ...current.skip(index + 1),
    ];
  }
}
