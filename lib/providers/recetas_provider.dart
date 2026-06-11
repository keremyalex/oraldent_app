import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/receta.dart';
import 'package:odontologia_app/services/recetas_service.dart';

class RecetasProvider extends ChangeNotifier {
  RecetasProvider(this._service);

  final RecetasService _service;

  final Map<int, List<Receta>> _recetasPorFicha = {};
  final Set<int> _fichasCargando = {};
  final Map<int, String> _erroresPorFicha = {};
  bool _isSaving = false;

  bool get isSaving => _isSaving;

  List<Receta> recetasDeFicha(int fichaId) {
    return _recetasPorFicha[fichaId] ?? const [];
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
      _recetasPorFicha[fichaId] = await _service.listarPorFicha(fichaId);
    } catch (error) {
      _erroresPorFicha[fichaId] = apiErrorMessage(error);
    } finally {
      _fichasCargando.remove(fichaId);
      notifyListeners();
    }
  }

  Future<void> loadIfNeeded(int fichaId) async {
    if (_recetasPorFicha.containsKey(fichaId) ||
        _fichasCargando.contains(fichaId)) {
      return;
    }
    await load(fichaId);
  }

  Future<String?> crear({
    required int fichaId,
    required RecetaRequest request,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final receta = await _service.crear(fichaId: fichaId, request: request);
      _recetasPorFicha[fichaId] = [receta, ...recetasDeFicha(fichaId)];
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> actualizar({
    required Receta receta,
    required RecetaRequest request,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final updated = await _service.actualizar(
        recetaId: receta.id,
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

  Future<String?> desactivar(Receta receta) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _service.desactivar(receta.id);
      _recetasPorFicha[receta.fichaClinicaId] = recetasDeFicha(
        receta.fichaClinicaId,
      ).where((item) => item.id != receta.id).toList();
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> abrirPdf(int recetaId) async {
    _isSaving = true;
    notifyListeners();

    try {
      final filePath = await _service.descargarPdf(recetaId);
      final result = await OpenFilex.open(filePath);
      if (result.type == ResultType.done) {
        return null;
      }
      return result.message.isEmpty
          ? 'No se pudo abrir el PDF.'
          : result.message;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _replace(Receta receta) {
    final recetas = recetasDeFicha(receta.fichaClinicaId);
    final index = recetas.indexWhere((item) => item.id == receta.id);
    if (index == -1) {
      _recetasPorFicha[receta.fichaClinicaId] = [receta, ...recetas];
      return;
    }
    _recetasPorFicha[receta.fichaClinicaId] = [
      ...recetas.take(index),
      receta,
      ...recetas.skip(index + 1),
    ];
  }
}
