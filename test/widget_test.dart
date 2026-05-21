import 'package:flutter_test/flutter_test.dart';
import 'package:odontologia_app/models/odontograma.dart';

void main() {
  test('parsea odontograma y detecta hallazgos', () {
    final odontograma = Odontograma.fromJson({
      'id': 1,
      'paciente': {
        'id': 10,
        'nombre': 'Maria',
        'apellidoPaterno': 'Rojas',
        'apellidoMaterno': null,
        'celular': '70010001',
        'documentoIdentidad': null,
        'correo': null,
        'fechaNacimiento': null,
        'direccion': null,
        'fotoUrl': null,
      },
      'usuarioId': 2,
      'citaId': null,
      'observaciones': 'Valoracion inicial',
      'activo': true,
      'dientes': [
        {
          'id': 100,
          'numeroFdi': 16,
          'cuadrante': 1,
          'posicion': 6,
          'ausente': false,
          'implante': false,
          'corona': false,
          'endodoncia': false,
          'extraccionIndicada': false,
          'movilidad': null,
          'observacion': null,
          'caras': [
            {
              'id': 1000,
              'tipo': OdontogramaCaraTipo.mesial,
              'color': OdontogramaColor.rojo,
              'descripcion': 'Caries proximal',
            },
          ],
        },
      ],
    });

    expect(odontograma.paciente.nombreCompleto, 'Maria Rojas');
    expect(odontograma.hallazgos, 1);
    expect(
      odontograma.dientePorFdi(16)?.cara(OdontogramaCaraTipo.mesial).color,
      OdontogramaColor.rojo,
    );
  });
}
