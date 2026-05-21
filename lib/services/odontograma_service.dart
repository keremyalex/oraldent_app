import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/odontograma.dart';

class OdontogramaDienteRequest {
  const OdontogramaDienteRequest({
    required this.ausente,
    required this.implante,
    required this.corona,
    required this.endodoncia,
    required this.extraccionIndicada,
    this.observacion,
  });

  final bool ausente;
  final bool implante;
  final bool corona;
  final bool endodoncia;
  final bool extraccionIndicada;
  final String? observacion;

  Map<String, dynamic> toJson() {
    return {
      'ausente': ausente,
      'implante': implante,
      'corona': corona,
      'endodoncia': endodoncia,
      'extraccionIndicada': extraccionIndicada,
      'observacion': observacion,
    };
  }
}

class OdontogramaService {
  const OdontogramaService(this._apiClient);

  final ApiClient _apiClient;

  Future<Odontograma> obtenerPorFicha(int fichaId) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/fichas/$fichaId/odontograma',
    );
    return Odontograma.fromJson(response.data!);
  }

  Future<Odontograma> actualizarObservaciones({
    required int odontogramaId,
    required String? observaciones,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/odontogramas/$odontogramaId/observaciones',
      data: {'observaciones': observaciones},
    );
    return Odontograma.fromJson(response.data!);
  }

  Future<Odontograma> actualizarCompleto({
    required Odontograma odontograma,
    required String? observaciones,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/odontogramas/${odontograma.id}',
      data: {
        'observaciones': observaciones,
        'dientes': odontograma.dientes.map((diente) {
          return {
            'numeroFdi': diente.numeroFdi,
            'ausente': diente.ausente,
            'implante': diente.implante,
            'corona': diente.corona,
            'endodoncia': diente.endodoncia,
            'extraccionIndicada': diente.extraccionIndicada,
            'observacion': diente.observacion,
            'caras': diente.caras.map((cara) {
              return {
                'tipo': cara.tipo,
                'color': cara.color,
                'descripcion': cara.descripcion,
              };
            }).toList(),
          };
        }).toList(),
      },
    );
    return Odontograma.fromJson(response.data!);
  }

  Future<Odontograma> actualizarDiente({
    required int odontogramaId,
    required int numeroFdi,
    required OdontogramaDienteRequest request,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/odontogramas/$odontogramaId/dientes/$numeroFdi',
      data: request.toJson(),
    );
    return Odontograma.fromJson(response.data!);
  }

  Future<Odontograma> actualizarCara({
    required int odontogramaId,
    required int numeroFdi,
    required String tipo,
    required String color,
    String? descripcion,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/odontogramas/$odontogramaId/dientes/$numeroFdi/caras/$tipo',
      data: {'color': color, 'descripcion': descripcion},
    );
    return Odontograma.fromJson(response.data!);
  }
}
