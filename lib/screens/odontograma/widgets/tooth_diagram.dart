import 'package:flutter/material.dart';
import 'package:odontologia_app/models/odontograma.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class ToothDiagram extends StatelessWidget {
  const ToothDiagram({
    required this.diente,
    this.selectedFace,
    this.onFaceTap,
    super.key,
  });

  final OdontogramaDiente diente;
  final String? selectedFace;
  final ValueChanged<String>? onFaceTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final diagram = CustomPaint(
          painter: _ToothDiagramPainter(
            diente: diente,
            selectedFace: selectedFace,
          ),
          child: const SizedBox.expand(),
        );

        if (onFaceTap == null) {
          return diagram;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final face = _ToothGeometry.faceAt(
              details.localPosition,
              Size(constraints.maxWidth, constraints.maxHeight),
              diente.cuadrante,
            );
            if (face != null) {
              onFaceTap!(face);
            }
          },
          child: diagram,
        );
      },
    );
  }
}

class _ToothDiagramPainter extends CustomPainter {
  const _ToothDiagramPainter({required this.diente, this.selectedFace});

  final OdontogramaDiente diente;
  final String? selectedFace;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeColor = size.shortestSide > 90
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);
    final stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide > 90 ? 1.6 : 1;
    final selectedStroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide > 90 ? 3 : 1.8;

    final paths = _ToothGeometry.paths(size, diente.cuadrante);
    for (final tipo in OdontogramaCaraTipo.all) {
      final path = paths[tipo];
      if (path == null) {
        continue;
      }
      final cara = diente.cara(tipo);
      canvas.drawPath(
        path,
        Paint()
          ..color = OdontogramaColor.asColor(cara.color)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(path, tipo == selectedFace ? selectedStroke : stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ToothDiagramPainter oldDelegate) {
    return oldDelegate.diente != diente ||
        oldDelegate.selectedFace != selectedFace;
  }
}

class _ToothGeometry {
  static Map<String, Path> paths(Size size, int cuadrante) {
    final side = size.shortestSide;
    final left = (size.width - side) / 2 + 1;
    final top = (size.height - side) / 2 + 1;
    final outer = Rect.fromLTWH(left, top, side - 2, side - 2);
    final inner = outer.deflate(outer.width * 0.30);

    final topFace = _topFace(cuadrante);
    final bottomFace = _bottomFace(cuadrante);
    final leftFace = _leftFace(cuadrante);
    final rightFace = _rightFace(cuadrante);

    return {
      topFace: Path()
        ..moveTo(outer.left, outer.top)
        ..lineTo(outer.right, outer.top)
        ..lineTo(inner.right, inner.top)
        ..lineTo(inner.left, inner.top)
        ..close(),
      rightFace: Path()
        ..moveTo(outer.right, outer.top)
        ..lineTo(outer.right, outer.bottom)
        ..lineTo(inner.right, inner.bottom)
        ..lineTo(inner.right, inner.top)
        ..close(),
      bottomFace: Path()
        ..moveTo(outer.right, outer.bottom)
        ..lineTo(outer.left, outer.bottom)
        ..lineTo(inner.left, inner.bottom)
        ..lineTo(inner.right, inner.bottom)
        ..close(),
      leftFace: Path()
        ..moveTo(outer.left, outer.bottom)
        ..lineTo(outer.left, outer.top)
        ..lineTo(inner.left, inner.top)
        ..lineTo(inner.left, inner.bottom)
        ..close(),
      OdontogramaCaraTipo.oclusal: Path()..addRect(inner),
    };
  }

  static String? faceAt(Offset position, Size size, int cuadrante) {
    final side = size.shortestSide;
    final left = (size.width - side) / 2 + 1;
    final top = (size.height - side) / 2 + 1;
    final outer = Rect.fromLTWH(left, top, side - 2, side - 2);
    if (!outer.contains(position)) {
      return null;
    }

    final inner = outer.deflate(outer.width * 0.30);
    if (inner.contains(position)) {
      return OdontogramaCaraTipo.oclusal;
    }
    if (position.dy < inner.top) {
      return _topFace(cuadrante);
    }
    if (position.dy > inner.bottom) {
      return _bottomFace(cuadrante);
    }
    if (position.dx < inner.left) {
      return _leftFace(cuadrante);
    }
    return _rightFace(cuadrante);
  }

  static String _topFace(int cuadrante) {
    return cuadrante == 3 || cuadrante == 4
        ? OdontogramaCaraTipo.palatino
        : OdontogramaCaraTipo.vestibular;
  }

  static String _bottomFace(int cuadrante) {
    return cuadrante == 3 || cuadrante == 4
        ? OdontogramaCaraTipo.vestibular
        : OdontogramaCaraTipo.palatino;
  }

  static String _leftFace(int cuadrante) {
    return cuadrante == 1 || cuadrante == 4
        ? OdontogramaCaraTipo.distal
        : OdontogramaCaraTipo.mesial;
  }

  static String _rightFace(int cuadrante) {
    return cuadrante == 1 || cuadrante == 4
        ? OdontogramaCaraTipo.mesial
        : OdontogramaCaraTipo.distal;
  }
}
