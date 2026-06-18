import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/periodontograma.dart';
import 'package:odontologia_app/models/periodontograma_ai.dart';
import 'package:odontologia_app/services/periodontograma_service.dart';

class PeriodontogramaProvider extends ChangeNotifier {
  PeriodontogramaProvider(this._service);

  final PeriodontogramaService _service;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  Periodontograma? _periodontograma;
  int? _currentFichaId;
  int _requestVersion = 0;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  Periodontograma? get periodontograma => _periodontograma;

  Future<void> loadPorFicha(int fichaId) async {
    final requestVersion = ++_requestVersion;
    final isDifferentFicha = _currentFichaId != fichaId;

    _isLoading = true;
    _errorMessage = null;
    _currentFichaId = fichaId;
    if (isDifferentFicha) {
      _periodontograma = null;
    }
    notifyListeners();

    try {
      final periodontograma = await _service.obtenerPorFicha(fichaId);
      if (requestVersion != _requestVersion) {
        return;
      }
      _periodontograma = periodontograma;
    } catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _errorMessage = apiErrorMessage(error);
      _periodontograma = null;
    } finally {
      if (requestVersion == _requestVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<String?> actualizarObservaciones(String value) async {
    final current = _periodontograma;
    if (current == null) {
      return 'No hay periodontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();
    try {
      _periodontograma = await _service.actualizarObservaciones(
        periodontogramaId: current.id,
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

  Future<String?> actualizarDiente({
    required PeriodontogramaDiente diente,
    required PeriodontogramaDienteRequest request,
  }) async {
    final current = _periodontograma;
    if (current == null) {
      return 'No hay periodontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();
    try {
      _periodontograma = await _service.actualizarDiente(
        periodontogramaId: current.id,
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

  Future<String?> actualizarSitio({
    required PeriodontogramaDiente diente,
    required PeriodontogramaSitio sitio,
    required PeriodontogramaSitioRequest request,
  }) async {
    final current = _periodontograma;
    if (current == null) {
      return 'No hay periodontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();
    try {
      _periodontograma = await _service.actualizarSitio(
        periodontogramaId: current.id,
        numeroFdi: diente.numeroFdi,
        sitio: sitio.sitio,
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

  Future<String?> aplicarResultadoIa(PeriodontogramaAiResult result) async {
    if (_periodontograma == null) {
      return 'No hay periodontograma cargado.';
    }
    if (!result.hasData) {
      return 'La IA no detecto datos para aplicar.';
    }

    _isSaving = true;
    notifyListeners();

    try {
      var current = _periodontograma!;
      for (final entry in result.byTooth.entries) {
        final numeroFdi = entry.key;
        final items = entry.value;
        var diente = current.dientePorFdi(numeroFdi);
        if (diente == null) {
          continue;
        }

        final dienteRequest = _buildDienteRequestFromAi(diente, items);
        if (dienteRequest != null) {
          current = await _service.actualizarDiente(
            periodontogramaId: current.id,
            numeroFdi: numeroFdi,
            request: dienteRequest,
          );
          diente = current.dientePorFdi(numeroFdi);
          if (diente == null) {
            continue;
          }
        }

        final siteChanges = _buildSitioChangesFromAi(diente, items);
        for (final change in siteChanges.entries) {
          final currentDiente = diente;
          if (currentDiente == null) {
            break;
          }
          final sitio = currentDiente.sitio(change.key);
          current = await _service.actualizarSitio(
            periodontogramaId: current.id,
            numeroFdi: numeroFdi,
            sitio: change.key,
            request: change.value(sitio),
          );
          diente = current.dientePorFdi(numeroFdi);
          if (diente == null) {
            break;
          }
        }
      }

      _periodontograma = current;
      return null;
    } catch (error) {
      return apiErrorMessage(error);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> abrirPdf({int? periodontogramaId}) async {
    final id = periodontogramaId ?? _periodontograma?.id;
    if (id == null) {
      return 'No hay periodontograma cargado.';
    }

    _isSaving = true;
    notifyListeners();

    try {
      final filePath = await _service.descargarPdf(id);
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

  PeriodontogramaDienteRequest? _buildDienteRequestFromAi(
    PeriodontogramaDiente diente,
    List<PeriodontogramaAiItem> items,
  ) {
    var movilidad = diente.movilidad;
    var furcacionVestibular = diente.furcacionVestibular;
    var furcacionPalatinaLingual = diente.furcacionPalatinaLingual;
    var changed = false;

    for (final item in items) {
      if (item.action == 'mobility' && item.grade != null) {
        movilidad = item.grade!.clamp(0, 3);
        changed = true;
      }
      if (item.action == 'furca' &&
          item.grade != null &&
          diente.permiteFurcacion) {
        final furcacion = _furcacionFromGrade(item.grade!);
        switch (item.surface) {
          case 'vestibular':
            furcacionVestibular = furcacion;
          case 'lingual':
            furcacionPalatinaLingual = furcacion;
          default:
            furcacionVestibular = furcacion;
            furcacionPalatinaLingual = furcacion;
        }
        changed = true;
      }
    }

    if (!changed) {
      return null;
    }

    return PeriodontogramaDienteRequest(
      ausente: diente.ausente,
      implante: diente.implante,
      movilidad: movilidad,
      furcacionVestibular: diente.permiteFurcacion
          ? furcacionVestibular
          : PeriodontogramaFurcacion.ninguna,
      furcacionPalatinaLingual: diente.permiteFurcacion
          ? furcacionPalatinaLingual
          : PeriodontogramaFurcacion.ninguna,
      observacion: diente.observacion,
    );
  }

  Map<String, PeriodontogramaSitioRequest Function(PeriodontogramaSitio)>
  _buildSitioChangesFromAi(
    PeriodontogramaDiente diente,
    List<PeriodontogramaAiItem> items,
  ) {
    final builders =
        <String, PeriodontogramaSitioRequest Function(PeriodontogramaSitio)>{};
    final affectedByProbing = <String>{};

    void addBuilder(
      String sitio,
      PeriodontogramaSitioRequest Function(PeriodontogramaSitio) builder,
    ) {
      final previous = builders[sitio];
      builders[sitio] = previous == null
          ? builder
          : (current) => builder(_requestAsSitio(sitio, previous(current)));
    }

    for (final item in items) {
      if (item.action != 'probing') {
        continue;
      }
      final sitios = _sitiosForSurface(item.surface);
      if (sitios == null || item.values.length < 3) {
        continue;
      }
      for (var index = 0; index < sitios.length; index += 1) {
        final sitio = sitios[index];
        final profundidad = item.values[index].clamp(0, 15);
        affectedByProbing.add(sitio);
        addBuilder(sitio, (current) {
          return PeriodontogramaSitioRequest(
            sangradoSondaje: current.sangradoSondaje,
            placa: current.placa,
            supuracion: current.supuracion,
            margenGingivalMm: current.margenGingivalMm,
            profundidadSondajeMm: profundidad,
            observacion: current.observacion,
          );
        });
      }
    }

    for (final item in items) {
      final targetSites = _targetSitesForItem(item, affectedByProbing);
      if (item.action == 'bleeding' && item.positive != null) {
        for (final sitio in targetSites) {
          addBuilder(sitio, (current) {
            return PeriodontogramaSitioRequest(
              sangradoSondaje: item.positive!,
              placa: current.placa,
              supuracion: current.supuracion,
              margenGingivalMm: current.margenGingivalMm,
              profundidadSondajeMm: current.profundidadSondajeMm,
              observacion: current.observacion,
            );
          });
        }
      }
      if (item.action == 'plaque' && item.positive != null) {
        for (final sitio in targetSites) {
          addBuilder(sitio, (current) {
            return PeriodontogramaSitioRequest(
              sangradoSondaje: current.sangradoSondaje,
              placa: item.positive!,
              supuracion: current.supuracion,
              margenGingivalMm: current.margenGingivalMm,
              profundidadSondajeMm: current.profundidadSondajeMm,
              observacion: current.observacion,
            );
          });
        }
      }
      if (item.action == 'suppuration' && item.positive != null) {
        for (final sitio in targetSites) {
          addBuilder(sitio, (current) {
            return PeriodontogramaSitioRequest(
              sangradoSondaje: current.sangradoSondaje,
              placa: current.placa,
              supuracion: item.positive!,
              margenGingivalMm: current.margenGingivalMm,
              profundidadSondajeMm: current.profundidadSondajeMm,
              observacion: current.observacion,
            );
          });
        }
      }
      if (item.action == 'recession' && item.mm != null) {
        for (final sitio in targetSites) {
          addBuilder(sitio, (current) {
            return PeriodontogramaSitioRequest(
              sangradoSondaje: current.sangradoSondaje,
              placa: current.placa,
              supuracion: current.supuracion,
              margenGingivalMm: item.mm!.clamp(-10, 15),
              profundidadSondajeMm: current.profundidadSondajeMm,
              observacion: current.observacion,
            );
          });
        }
      }
    }

    return builders;
  }

  List<String> _targetSitesForItem(
    PeriodontogramaAiItem item,
    Set<String> affectedByProbing,
  ) {
    final exactSites = item.sites
        .map(_sitioFromAi)
        .whereType<String>()
        .toSet()
        .toList();
    if (exactSites.isNotEmpty) {
      return exactSites;
    }

    final surfaceSites = _sitiosForSurface(item.surface);
    if (surfaceSites != null) {
      return surfaceSites;
    }

    if (affectedByProbing.isNotEmpty) {
      return affectedByProbing.toList();
    }

    return PeriodontogramaSitioTipo.all;
  }

  PeriodontogramaSitio _requestAsSitio(
    String sitio,
    PeriodontogramaSitioRequest request,
  ) {
    return PeriodontogramaSitio(
      id: 0,
      sitio: sitio,
      sangradoSondaje: request.sangradoSondaje,
      placa: request.placa,
      supuracion: request.supuracion,
      margenGingivalMm: request.margenGingivalMm,
      profundidadSondajeMm: request.profundidadSondajeMm,
      nivelInsercionMm: request.profundidadSondajeMm - request.margenGingivalMm,
      observacion: request.observacion,
    );
  }

  List<String>? _sitiosForSurface(String? surface) {
    return switch (surface) {
      'vestibular' => PeriodontogramaSitioGrupo.vestibular.sitios,
      'lingual' => PeriodontogramaSitioGrupo.palatinaLingual.sitios,
      _ => null,
    };
  }

  String? _sitioFromAi(String value) {
    final normalized = value.toLowerCase().replaceAll('_', '');
    return switch (normalized) {
      'mesiovestibular' => PeriodontogramaSitioTipo.mesioVestibular,
      'vestibular' => PeriodontogramaSitioTipo.vestibular,
      'distovestibular' => PeriodontogramaSitioTipo.distoVestibular,
      'mesiopalatino' ||
      'mesiolingual' => PeriodontogramaSitioTipo.mesioPalatino,
      'palatino' || 'lingual' => PeriodontogramaSitioTipo.palatino,
      'distopalatino' ||
      'distolingual' => PeriodontogramaSitioTipo.distoPalatino,
      _ => null,
    };
  }

  String _furcacionFromGrade(int grade) {
    return switch (grade) {
      <= 0 => PeriodontogramaFurcacion.ninguna,
      1 => PeriodontogramaFurcacion.gradoI,
      2 => PeriodontogramaFurcacion.gradoII,
      _ => PeriodontogramaFurcacion.gradoIII,
    };
  }
}
