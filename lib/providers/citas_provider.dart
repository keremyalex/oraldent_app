import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/cita.dart';
import 'package:odontologia_app/services/citas_service.dart';

class CitasProvider extends ChangeNotifier {
  CitasProvider(this._citasService);

  final CitasService _citasService;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<Cita> _citas = [];

  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<Cita> get citas => _citas;

  Future<void> load({DateTime? date}) async {
    if (date != null) {
      _selectedDate = DateTime(date.year, date.month, date.day);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _citas = await _citasService.listarPorFecha(_selectedDate);
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> disponibilidad(DateTime fecha) {
    return _citasService.disponibilidad(fecha);
  }

  Future<String?> crear(CitaRequest request) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _citasService.crear(request);
      await load(date: request.fechaHoraInicio);
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> reprogramar({
    required Cita cita,
    required DateTime nuevaFechaHoraInicio,
  }) async {
    final codigoGestion = cita.codigoGestion;
    if (codigoGestion == null || codigoGestion.isEmpty) {
      return 'La cita no tiene codigo de gestion.';
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _citasService.reprogramar(
        id: cita.id,
        codigoGestion: codigoGestion,
        nuevaFechaHoraInicio: nuevaFechaHoraInicio,
      );
      await load(date: nuevaFechaHoraInicio);
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
