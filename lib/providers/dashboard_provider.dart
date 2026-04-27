import 'package:flutter/foundation.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/cita.dart';
import 'package:odontologia_app/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._dashboardService);

  final DashboardService _dashboardService;

  bool _isLoading = false;
  String? _errorMessage;
  List<Cita> _citas = [];
  int _pacientesCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Cita> get citas => _citas;
  int get pacientesCount => _pacientesCount;
  int get citasCount => _citas.length;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _dashboardService.fetchDashboard();
      _citas = data.citas;
      _pacientesCount = data.pacientes.length;
    } catch (error) {
      _errorMessage = apiErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
