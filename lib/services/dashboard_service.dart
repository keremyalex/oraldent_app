import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/cita.dart';
import 'package:odontologia_app/models/paciente.dart';

class DashboardData {
  const DashboardData({
    required this.citas,
    required this.pacientes,
  });

  final List<Cita> citas;
  final List<Paciente> pacientes;
}

class DashboardService {
  const DashboardService(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardData> fetchDashboard() async {
    final responses = await Future.wait([
      _apiClient.dio.get<List<dynamic>>('/api/citas'),
      _apiClient.dio.get<List<dynamic>>('/api/pacientes'),
    ]);

    final citas = responses[0].data!
        .cast<Map<String, dynamic>>()
        .map(Cita.fromJson)
        .toList();
    final pacientes = responses[1].data!
        .cast<Map<String, dynamic>>()
        .map(Paciente.fromJson)
        .toList();

    return DashboardData(citas: citas, pacientes: pacientes);
  }
}
