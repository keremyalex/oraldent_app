import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/servicio.dart';

class ServicioRequest {
  const ServicioRequest({
    required this.nombre,
    this.descripcion,
  });

  final String nombre;
  final String? descripcion;

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}

class ServiciosService {
  const ServiciosService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Servicio>> listar() async {
    final response = await _apiClient.dio.get<List<dynamic>>('/api/servicios');

    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Servicio.fromJson)
        .toList();
  }

  Future<Servicio> crear(ServicioRequest request) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/servicios',
      data: request.toJson(),
    );
    return Servicio.fromJson(response.data!);
  }

  Future<Servicio> actualizar(int id, ServicioRequest request) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/servicios/$id',
      data: request.toJson(),
    );
    return Servicio.fromJson(response.data!);
  }

  Future<void> desactivar(int id) async {
    await _apiClient.dio.delete<void>('/api/servicios/$id');
  }
}
