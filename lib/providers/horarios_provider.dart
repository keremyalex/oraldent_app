import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/horario_atencion.dart';
import 'package:odontologia_app/services/horarios_service.dart';

class HorariosProvider extends ChangeNotifier {
  HorariosProvider(this._horariosService);

  final HorariosService _horariosService;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<HorarioAtencion> _horarios = [];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<HorarioAtencion> get horarios => _horarios;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _horarios = await _horariosService.listar()
        ..sort((a, b) {
          final dayComparison =
              _dayOrder(a.diaSemana).compareTo(_dayOrder(b.diaSemana));
          if (dayComparison != 0) {
            return dayComparison;
          }
          final startComparison = a.horaInicio.hour.compareTo(
            b.horaInicio.hour,
          );
          if (startComparison != 0) {
            return startComparison;
          }
          return a.horaInicio.minute.compareTo(b.horaInicio.minute);
        });
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> save({
    int? id,
    required HorarioRequest request,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      if (id == null) {
        await _horariosService.crear(request);
      } else {
        await _horariosService.actualizar(id, request);
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
      await _horariosService.desactivar(id);
      await load();
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  int _dayOrder(String day) {
    return switch (day) {
      'LUNES' || 'MONDAY' => 1,
      'MARTES' || 'TUESDAY' => 2,
      'MIERCOLES' || 'WEDNESDAY' => 3,
      'JUEVES' || 'THURSDAY' => 4,
      'VIERNES' || 'FRIDAY' => 5,
      'SABADO' || 'SATURDAY' => 6,
      'DOMINGO' || 'SUNDAY' => 7,
      _ => 99,
    };
  }
}
