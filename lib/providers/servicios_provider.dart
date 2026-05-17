import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/servicio.dart';
import 'package:odontologia_app/services/servicios_service.dart';

class ServiciosProvider extends ChangeNotifier {
  ServiciosProvider(this._serviciosService);

  final ServiciosService _serviciosService;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<Servicio> _servicios = [];
  bool _hasLoaded = false;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<Servicio> get servicios => _servicios;
  bool get hasLoaded => _hasLoaded;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _servicios = await _serviciosService.listar()
        ..sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
        );
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

  Future<String?> save({
    int? id,
    required ServicioRequest request,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      if (id == null) {
        await _serviciosService.crear(request);
      } else {
        await _serviciosService.actualizar(id, request);
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

  Future<String?> delete(int id) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _serviciosService.desactivar(id);
      await load();
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
