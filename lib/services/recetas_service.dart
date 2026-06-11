import 'package:path_provider/path_provider.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/receta.dart';

class RecetaRequest {
  const RecetaRequest({
    required this.detalles,
    this.indicacionesGenerales,
    this.observaciones,
  });

  final String? indicacionesGenerales;
  final String? observaciones;
  final List<RecetaDetalleRequest> detalles;

  Map<String, dynamic> toJson() {
    return {
      'indicacionesGenerales': indicacionesGenerales,
      'observaciones': observaciones,
      'detalles': detalles.map((detalle) => detalle.toJson()).toList(),
    };
  }
}

class RecetaDetalleRequest {
  const RecetaDetalleRequest({
    required this.medicamento,
    this.dosis,
    this.frecuencia,
    this.duracion,
    this.indicaciones,
    this.orden,
  });

  final String medicamento;
  final String? dosis;
  final String? frecuencia;
  final String? duracion;
  final String? indicaciones;
  final int? orden;

  Map<String, dynamic> toJson() {
    return {
      'medicamento': medicamento,
      'dosis': dosis,
      'frecuencia': frecuencia,
      'duracion': duracion,
      'indicaciones': indicaciones,
      'orden': orden,
    };
  }
}

class RecetasService {
  const RecetasService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Receta>> listarPorFicha(int fichaId) async {
    final response = await _apiClient.dio.get<List<dynamic>>(
      '/api/fichas/$fichaId/recetas',
    );
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Receta.fromJson)
        .toList();
  }

  Future<Receta> crear({
    required int fichaId,
    required RecetaRequest request,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/fichas/$fichaId/recetas',
      data: request.toJson(),
    );
    return Receta.fromJson(response.data!);
  }

  Future<Receta> actualizar({
    required int recetaId,
    required RecetaRequest request,
  }) async {
    final response = await _apiClient.dio.put<Map<String, dynamic>>(
      '/api/recetas/$recetaId',
      data: request.toJson(),
    );
    return Receta.fromJson(response.data!);
  }

  Future<void> desactivar(int recetaId) async {
    await _apiClient.dio.delete<void>('/api/recetas/$recetaId');
  }

  Future<String> descargarPdf(int recetaId) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/receta_$recetaId.pdf';
    await _apiClient.dio.download('/api/recetas/$recetaId/pdf', filePath);
    return filePath;
  }
}
