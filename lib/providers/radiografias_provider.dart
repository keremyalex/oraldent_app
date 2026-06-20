import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/analisis_radiografia.dart';
import 'package:odontologia_app/models/radiografia.dart';
import 'package:odontologia_app/services/radiografias_service.dart';

class RadiografiasProvider extends ChangeNotifier {
  RadiografiasProvider(this._service);

  final RadiografiasService _service;

  final Map<int, List<Radiografia>> _radiografiasPorFicha = {};
  final Map<int, List<AnalisisRadiografia>> _analisisPorRadiografia = {};
  final Set<int> _fichasCargando = {};
  final Set<int> _radiografiasAnalizando = {};
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

  bool analizandoRadiografia(int radiografiaId) {
    return _radiografiasAnalizando.contains(radiografiaId);
  }

  AnalisisRadiografia? ultimoAnalisis(int radiografiaId) {
    final items = _analisisPorRadiografia[radiografiaId] ?? const [];
    return items.isEmpty ? null : items.first;
  }

  Future<void> load(int fichaId) async {
    _fichasCargando.add(fichaId);
    _erroresPorFicha.remove(fichaId);
    notifyListeners();

    try {
      final radiografias = await _service.listarPorFicha(fichaId);
      _radiografiasPorFicha[fichaId] = radiografias;
      await _loadAnalisisDeRadiografias(radiografias);
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

  Future<String?> analizarConIa(Radiografia radiografia) async {
    _radiografiasAnalizando.add(radiografia.id);
    notifyListeners();

    try {
      final analisis = await _service.analizarConIa(radiografia.id);
      _analisisPorRadiografia[radiografia.id] = [
        analisis,
        ...(_analisisPorRadiografia[radiografia.id] ?? const []),
      ];
      _radiografiasPorFicha[radiografia.fichaClinicaId] = await _service
          .listarPorFicha(radiografia.fichaClinicaId);
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _radiografiasAnalizando.remove(radiografia.id);
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

  Future<void> _loadAnalisisDeRadiografias(
    List<Radiografia> radiografias,
  ) async {
    for (final radiografia in radiografias) {
      try {
        _analisisPorRadiografia[radiografia.id] = await _service.listarAnalisis(
          radiografia.id,
        );
      } catch (_) {
        _analisisPorRadiografia[radiografia.id] = const [];
      }
    }
  }
}
