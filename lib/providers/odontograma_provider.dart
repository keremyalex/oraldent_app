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
  Odontograma? _originalOdontograma;
  bool _isEditing = false;
  bool _hasChanges = false;
  int? _currentFichaId;
  int _requestVersion = 0;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  Odontograma? get odontograma => _odontograma;
  bool get isEditing => _isEditing;
  bool get hasChanges => _hasChanges;

  Future<void> loadPorFicha(int fichaId) async {
    final requestVersion = ++_requestVersion;
    final isDifferentFicha = _currentFichaId != fichaId;

    _isLoading = true;
    _errorMessage = null;
    _currentFichaId = fichaId;
    if (isDifferentFicha) {
      _odontograma = null;
      _originalOdontograma = null;
      _isEditing = false;
      _hasChanges = false;
    }
    notifyListeners();

    try {
      final odontograma = await _odontogramaService.obtenerPorFicha(fichaId);
      if (requestVersion != _requestVersion) {
        return;
      }
      _odontograma = odontograma;
      _originalOdontograma = _odontograma;
      _isEditing = false;
      _hasChanges = false;
    } catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _errorMessage = apiErrorMessage(error);
      _odontograma = null;
      _originalOdontograma = null;
      _isEditing = false;
      _hasChanges = false;
    } finally {
      if (requestVersion == _requestVersion) {
        _isLoading = false;
        notifyListeners();
      }
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

  void startEditing() {
    _originalOdontograma = _odontograma;
    _isEditing = true;
    notifyListeners();
  }

  void discardEditing() {
    _odontograma = _originalOdontograma ?? _odontograma;
    _isEditing = false;
    _hasChanges = false;
    notifyListeners();
  }

  void actualizarDienteLocal({
    required int numeroFdi,
    required bool ausente,
    required bool implante,
    required bool corona,
    required bool endodoncia,
    required bool extraccionIndicada,
    required String? observacion,
  }) {
    final current = _odontograma;
    if (current == null) {
      return;
    }
    _odontograma = current.copyWith(
      observaciones: current.observaciones,
      dientes: current.dientes.map((diente) {
        if (diente.numeroFdi != numeroFdi) {
          return diente;
        }
        return diente.copyWith(
          ausente: ausente,
          implante: ausente ? false : implante,
          corona: ausente ? false : corona,
          endodoncia: ausente ? false : endodoncia,
          extraccionIndicada: ausente ? false : extraccionIndicada,
          observacion: observacion,
          clearObservacion: observacion == null,
        );
      }).toList(),
    );
    _hasChanges = true;
    notifyListeners();
  }

  void alternarCaraLocal({required int numeroFdi, required String tipo}) {
    final current = _odontograma;
    if (current == null) {
      return;
    }
    _odontograma = current.copyWith(
      observaciones: current.observaciones,
      dientes: current.dientes.map((diente) {
        if (diente.numeroFdi != numeroFdi) {
          return diente;
        }
        return diente.copyWith(
          caras: diente.caras.map((cara) {
            if (cara.tipo != tipo) {
              return cara;
            }
            return cara.copyWith(color: OdontogramaColor.next(cara.color));
          }).toList(),
        );
      }).toList(),
    );
    _hasChanges = true;
    notifyListeners();
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

  Future<String?> guardarOdontograma(String observaciones) async {
    final current = _odontograma;
    if (current == null) {
      return 'No hay odontograma cargado.';
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _odontograma = await _odontogramaService.actualizarCompleto(
        odontograma: current,
        observaciones: observaciones.trim().isEmpty
            ? null
            : observaciones.trim(),
      );
      _originalOdontograma = _odontograma;
      _isEditing = false;
      _hasChanges = false;
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
