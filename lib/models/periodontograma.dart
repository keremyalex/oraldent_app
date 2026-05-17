import 'package:odontologia_app/models/paciente.dart';

class Periodontograma {
  const Periodontograma({
    required this.id,
    required this.paciente,
    required this.activo,
    required this.dientes,
    this.usuarioId,
    this.citaId,
    this.observaciones,
  });

  factory Periodontograma.fromJson(Map<String, dynamic> json) {
    return Periodontograma(
      id: json['id'] as int,
      paciente: Paciente.fromJson(json['paciente'] as Map<String, dynamic>),
      usuarioId: json['usuarioId'] as int?,
      citaId: json['citaId'] as int?,
      observaciones: json['observaciones'] as String?,
      activo: json['activo'] as bool? ?? true,
      dientes: (json['dientes'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(PeriodontogramaDiente.fromJson)
          .toList(),
    );
  }

  final int id;
  final Paciente paciente;
  final int? usuarioId;
  final int? citaId;
  final String? observaciones;
  final bool activo;
  final List<PeriodontogramaDiente> dientes;

  PeriodontogramaDiente? dientePorFdi(int numeroFdi) {
    for (final diente in dientes) {
      if (diente.numeroFdi == numeroFdi) {
        return diente;
      }
    }
    return null;
  }

  int get sitiosConSangrado => dientes
      .expand((diente) => diente.sitios)
      .where((sitio) => sitio.sangradoSondaje)
      .length;

  int get sitiosConPlaca => dientes
      .expand((diente) => diente.sitios)
      .where((sitio) => sitio.placa)
      .length;

  int get sitiosConSupuracion => dientes
      .expand((diente) => diente.sitios)
      .where((sitio) => sitio.supuracion)
      .length;

  int get profundidadMaxima {
    var maximo = 0;
    for (final sitio in dientes.expand((diente) => diente.sitios)) {
      if (sitio.profundidadSondajeMm > maximo) {
        maximo = sitio.profundidadSondajeMm;
      }
    }
    return maximo;
  }
}

class PeriodontogramaDiente {
  const PeriodontogramaDiente({
    required this.id,
    required this.numeroFdi,
    required this.cuadrante,
    required this.posicion,
    required this.ausente,
    required this.implante,
    required this.furcacion,
    required this.sitios,
    this.movilidad,
    this.observacion,
  });

  factory PeriodontogramaDiente.fromJson(Map<String, dynamic> json) {
    return PeriodontogramaDiente(
      id: json['id'] as int,
      numeroFdi: json['numeroFdi'] as int,
      cuadrante: json['cuadrante'] as int,
      posicion: json['posicion'] as int,
      ausente: json['ausente'] as bool? ?? false,
      implante: json['implante'] as bool? ?? false,
      movilidad: json['movilidad'] as int?,
      furcacion:
          json['furcacion'] as String? ?? PeriodontogramaFurcacion.ninguna,
      observacion: json['observacion'] as String?,
      sitios: (json['sitios'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(PeriodontogramaSitio.fromJson)
          .toList(),
    );
  }

  final int id;
  final int numeroFdi;
  final int cuadrante;
  final int posicion;
  final bool ausente;
  final bool implante;
  final int? movilidad;
  final String furcacion;
  final String? observacion;
  final List<PeriodontogramaSitio> sitios;

  bool get tieneHallazgos {
    return ausente ||
        implante ||
        movilidad != null ||
        furcacion != PeriodontogramaFurcacion.ninguna ||
        (observacion != null && observacion!.isNotEmpty) ||
        sitios.any((sitio) => sitio.tieneHallazgos);
  }

  PeriodontogramaSitio sitio(String tipo) {
    return sitios.firstWhere(
      (sitio) => sitio.sitio == tipo,
      orElse: () => PeriodontogramaSitio.vacio(tipo),
    );
  }
}

class PeriodontogramaSitio {
  const PeriodontogramaSitio({
    required this.id,
    required this.sitio,
    required this.sangradoSondaje,
    required this.placa,
    required this.supuracion,
    required this.margenGingivalMm,
    required this.profundidadSondajeMm,
    required this.nivelInsercionMm,
    this.observacion,
  });

  factory PeriodontogramaSitio.fromJson(Map<String, dynamic> json) {
    return PeriodontogramaSitio(
      id: json['id'] as int,
      sitio: json['sitio'] as String,
      sangradoSondaje: json['sangradoSondaje'] as bool? ?? false,
      placa: json['placa'] as bool? ?? false,
      supuracion: json['supuracion'] as bool? ?? false,
      margenGingivalMm: json['margenGingivalMm'] as int? ?? 0,
      profundidadSondajeMm: json['profundidadSondajeMm'] as int? ?? 0,
      nivelInsercionMm: json['nivelInsercionMm'] as int? ?? 0,
      observacion: json['observacion'] as String?,
    );
  }

  const PeriodontogramaSitio.vacio(this.sitio)
    : id = 0,
      sangradoSondaje = false,
      placa = false,
      supuracion = false,
      margenGingivalMm = 0,
      profundidadSondajeMm = 0,
      nivelInsercionMm = 0,
      observacion = null;

  final int id;
  final String sitio;
  final bool sangradoSondaje;
  final bool placa;
  final bool supuracion;
  final int margenGingivalMm;
  final int profundidadSondajeMm;
  final int nivelInsercionMm;
  final String? observacion;

  bool get tieneHallazgos {
    return sangradoSondaje ||
        placa ||
        supuracion ||
        margenGingivalMm != 0 ||
        profundidadSondajeMm != 0 ||
        nivelInsercionMm != 0 ||
        (observacion != null && observacion!.isNotEmpty);
  }
}

class PeriodontogramaSitioTipo {
  static const mesioVestibular = 'MESIOVESTIBULAR';
  static const vestibular = 'VESTIBULAR';
  static const distoVestibular = 'DISTOVESTIBULAR';
  static const mesioPalatino = 'MESIOPALATINO';
  static const palatino = 'PALATINO';
  static const distoPalatino = 'DISTOPALATINO';

  static const all = [
    mesioVestibular,
    vestibular,
    distoVestibular,
    mesioPalatino,
    palatino,
    distoPalatino,
  ];

  static String label(String value) {
    return switch (value) {
      mesioVestibular => 'MV',
      vestibular => 'V',
      distoVestibular => 'DV',
      mesioPalatino => 'MP',
      palatino => 'P',
      distoPalatino => 'DP',
      _ => value,
    };
  }
}

class PeriodontogramaFurcacion {
  static const ninguna = 'NINGUNA';
  static const gradoI = 'GRADO_I';
  static const gradoII = 'GRADO_II';
  static const gradoIII = 'GRADO_III';

  static const all = [ninguna, gradoI, gradoII, gradoIII];

  static String label(String value) {
    return switch (value) {
      gradoI => 'Grado I',
      gradoII => 'Grado II',
      gradoIII => 'Grado III',
      _ => 'Ninguna',
    };
  }
}
