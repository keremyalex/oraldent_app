import 'package:flutter/material.dart';
import 'package:odontologia_app/models/periodontograma.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class PeriodontogramaChartSection extends StatelessWidget {
  const PeriodontogramaChartSection({required this.periodontograma, super.key});

  final Periodontograma periodontograma;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Vista grafica periodontal',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.inverted,
                    fontSize: 15,
                  ),
                ),
              ),
              const _Legend(color: Color(0xFFDC2626), label: 'Margen'),
              const SizedBox(width: 12),
              const _Legend(color: Color(0xFF2563EB), label: 'Sondaje'),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 790,
              height: 720,
              child: Stack(
                children: [
                  _ChartImage(
                    top: 0,
                    asset: 'assets/periodontogram/chart/ok-teeth-01.jpg',
                  ),
                  _ChartImage(
                    top: 176,
                    asset: 'assets/periodontogram/chart/ok-teeth-02.jpg',
                  ),
                  _ChartImage(
                    top: 382,
                    asset: 'assets/periodontogram/chart/uk-teeth-01.jpg',
                  ),
                  _ChartImage(
                    top: 558,
                    asset: 'assets/periodontogram/chart/uk-teeth-02.jpg',
                  ),
                  ..._implantOverlays(periodontograma),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PeriodontalChartPainter(periodontograma),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _implantOverlays(Periodontograma periodontograma) {
    return [
      for (final diente in periodontograma.dientes)
        if (diente.implante) ...[
          if (diente.numeroFdi >= 11 && diente.numeroFdi <= 28) ...[
            _ImplantOverlay(
              asset: _implantAsset(diente.numeroFdi, 'b'),
              x: _implantX(diente.numeroFdi, 'b'),
              y: _implantY(diente.numeroFdi, 'b') + 0,
            ),
            _ImplantOverlay(
              asset: _implantAsset(diente.numeroFdi, 'p'),
              x: _implantX(diente.numeroFdi, 'p'),
              y: _implantY(diente.numeroFdi, 'p') + 176,
            ),
          ] else ...[
            _ImplantOverlay(
              asset: _implantAsset(diente.numeroFdi, 'l'),
              x: _implantX(diente.numeroFdi, 'l'),
              y: _implantY(diente.numeroFdi, 'l') + 382,
            ),
            _ImplantOverlay(
              asset: _implantAsset(diente.numeroFdi, 'b'),
              x: _implantX(diente.numeroFdi, 'b'),
              y: _implantY(diente.numeroFdi, 'b') + 558,
            ),
          ],
        ],
    ];
  }

  String _implantAsset(int tooth, String side) {
    final quadrant = tooth ~/ 10;
    return 'assets/periodontogram/chart/implants/$quadrant/$tooth$side.png';
  }

  double _implantX(int tooth, String side) =>
      _implantCoordinates['$tooth$side']!.$1;
  double _implantY(int tooth, String side) =>
      _implantCoordinates['$tooth$side']!.$2;
}

class _ChartImage extends StatelessWidget {
  const _ChartImage({required this.top, required this.asset});

  final double top;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -9,
      top: top,
      width: 810,
      height: 162,
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

class _ImplantOverlay extends StatelessWidget {
  const _ImplantOverlay({
    required this.asset,
    required this.x,
    required this.y,
  });

  final String asset;
  final double x;
  final double y;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x - 35,
      top: y - 66,
      width: 70,
      height: 132,
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

const _implantCoordinates = <String, (double, double)>{
  '18b': (26, 57),
  '18p': (26, 105),
  '17b': (82.7, 57),
  '17p': (82.7, 105),
  '16b': (140.1, 57),
  '16p': (140.4, 105),
  '15b': (191.1, 57),
  '15p': (191.1, 105),
  '14b': (233, 57),
  '14p': (233, 105),
  '13b': (275.3, 57),
  '13p': (275.3, 105),
  '12b': (314.4, 57),
  '12p': (314.5, 105.8),
  '11b': (363.9, 57),
  '11p': (363.9, 106),
  '21b': (424.9, 57),
  '21p': (424.9, 106),
  '22b': (473.6, 57),
  '22p': (473.4, 105.8),
  '23b': (512.7, 57),
  '23p': (512.7, 105),
  '24b': (555, 57),
  '24p': (554.4, 105),
  '25b': (596, 57),
  '25p': (596, 105),
  '26b': (646.8, 57),
  '26p': (646.8, 105),
  '27b': (704.8, 57),
  '27p': (704.8, 105),
  '28b': (762, 57),
  '28p': (761.8, 105),
  '31b': (415, 112),
  '31l': (415.9, 54),
  '32b': (454.5, 112),
  '32l': (455, 54),
  '33b': (492, 112),
  '33l': (491, 54),
  '34b': (530, 112),
  '34l': (529, 54),
  '35b': (570.9, 112),
  '35l': (570.9, 54),
  '36b': (625, 112),
  '36l': (623, 54),
  '37b': (689.4, 112),
  '37l': (684.9, 54),
  '38b': (759.9, 112),
  '38l': (757.5, 54),
  '41b': (373.2, 112),
  '41l': (371.9, 54),
  '42b': (333, 112),
  '42l': (331.9, 54),
  '43b': (294.9, 112),
  '43l': (296.6, 54),
  '44b': (257, 112),
  '44l': (258.9, 54),
  '45b': (217.4, 112),
  '45l': (217.5, 54),
  '46b': (162.5, 112),
  '46l': (165.4, 54),
  '47b': (98.9, 112),
  '47l': (103.4, 54),
  '48b': (36, 112),
  '48l': (38.4, 54),
};

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 3, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _PeriodontalChartPainter extends CustomPainter {
  const _PeriodontalChartPainter(this.periodontograma);

  final Periodontograma periodontograma;

  static const _scale = 6.45;
  static const _upperTeeth = [
    18,
    17,
    16,
    15,
    14,
    13,
    12,
    11,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
  ];
  static const _lowerTeeth = [
    48,
    47,
    46,
    45,
    44,
    43,
    42,
    41,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
  ];

  static const _x = <int, _ToothX>{
    11: _ToothX(mb: 377, db: 345, mp: 375, dp: 344),
    12: _ToothX(mb: 329, db: 305, mp: 329, dp: 303),
    13: _ToothX(mb: 287, db: 261, mp: 290, dp: 263),
    14: _ToothX(mb: 245, db: 221, mp: 246, dp: 221),
    15: _ToothX(mb: 206, db: 180, mp: 204, dp: 178),
    16: _ToothX(mb: 168, db: 114, mp: 162, dp: 116),
    17: _ToothX(mb: 103, db: 63, mp: 100, dp: 61),
    18: _ToothX(mb: 49, db: 12, mp: 48, dp: 8),
    21: _ToothX(mb: 415, db: 446, mp: 417, dp: 448),
    22: _ToothX(mb: 463, db: 487, mp: 463, dp: 489),
    23: _ToothX(mb: 504, db: 532, mp: 502, dp: 530),
    24: _ToothX(mb: 546, db: 572, mp: 546, dp: 571),
    25: _ToothX(mb: 586, db: 612, mp: 588, dp: 614),
    26: _ToothX(mb: 624, db: 678, mp: 629, dp: 677),
    27: _ToothX(mb: 689, db: 728, mp: 693, dp: 732),
    28: _ToothX(mb: 743, db: 780, mp: 745, dp: 784),
    31: _ToothX(mb: 412, db: 431, ml: 415, dl: 432),
    32: _ToothX(mb: 445, db: 465, ml: 450, dl: 468),
    33: _ToothX(mb: 483, db: 504, ml: 484, dl: 504),
    34: _ToothX(mb: 522, db: 541, ml: 521, dl: 544),
    35: _ToothX(mb: 562, db: 581, ml: 562, dl: 585),
    36: _ToothX(mb: 604, db: 653, ml: 604, dl: 649),
    37: _ToothX(mb: 669, db: 716, ml: 664, dl: 712),
    38: _ToothX(mb: 733, db: 778, ml: 729, dl: 778),
    41: _ToothX(mb: 379, db: 360, ml: 378, dl: 359),
    42: _ToothX(mb: 346, db: 327, ml: 342, dl: 324),
    43: _ToothX(mb: 309, db: 287, ml: 307, dl: 287),
    44: _ToothX(mb: 270, db: 250, ml: 270, dl: 248),
    45: _ToothX(mb: 230, db: 209, ml: 230, dl: 206),
    46: _ToothX(mb: 186, db: 139, ml: 186, dl: 142),
    47: _ToothX(mb: 123, db: 75, ml: 127, dl: 79),
    48: _ToothX(mb: 59, db: 13, ml: 63, dl: 14),
  };

  @override
  void paint(Canvas canvas, Size size) {
    _drawBand(canvas, teeth: _upperTeeth, band: const _Band.upperBuccal());
    _drawBand(canvas, teeth: _upperTeeth, band: const _Band.upperPalatal());
    _drawBand(canvas, teeth: _lowerTeeth, band: const _Band.lowerLingual());
    _drawBand(canvas, teeth: _lowerTeeth, band: const _Band.lowerBuccal());
    _drawToothNumbers(canvas, teeth: _upperTeeth, y: 171);
    _drawToothNumbers(canvas, teeth: _lowerTeeth, y: 553);
  }

  void _drawBand(
    Canvas canvas, {
    required List<int> teeth,
    required _Band band,
  }) {
    _drawGrid(canvas, band);

    final gmSegments = <List<Offset>>[];
    final pdSegments = <List<Offset>>[];
    var currentGm = <Offset>[];
    var currentPd = <Offset>[];

    for (final tooth in teeth) {
      final diente = periodontograma.dientePorFdi(tooth);
      if (diente == null || diente.ausente) {
        if (currentGm.isNotEmpty) {
          gmSegments.add(currentGm);
          pdSegments.add(currentPd);
          currentGm = <Offset>[];
          currentPd = <Offset>[];
        }
        continue;
      }

      final points = _pointsForTooth(diente, band);
      currentGm.addAll(points.$1);
      currentPd.addAll(points.$2);
    }

    if (currentGm.isNotEmpty) {
      gmSegments.add(currentGm);
      pdSegments.add(currentPd);
    }

    _drawSegments(canvas, pdSegments, const Color(0xFF2563EB));
    _drawSegments(canvas, gmSegments, const Color(0xFFDC2626));
  }

  void _drawGrid(Canvas canvas, _Band band) {
    final paint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.15;
    final baselineY = band.top + band.zeroLine;
    for (var i = 0; i <= 16; i++) {
      final y = baselineY + i * _scale * band.gridDirection;
      if (y >= band.top && y <= band.top + 162) {
        canvas.drawLine(
          const Offset(12, 0).translate(0, y),
          Offset(780, y),
          paint,
        );
      }
    }
  }

  void _drawToothNumbers(
    Canvas canvas, {
    required List<int> teeth,
    required double y,
  }) {
    final painter = TextPainter(textDirection: TextDirection.ltr);
    for (final tooth in teeth) {
      final coords = _x[tooth]!;
      final x = (coords.mb + coords.db) / 2;
      painter.text = TextSpan(
        text: '$tooth',
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
      painter.layout();
      painter.paint(canvas, Offset(x - painter.width / 2, y - painter.height));
    }
  }

  (List<Offset>, List<Offset>) _pointsForTooth(
    PeriodontogramaDiente diente,
    _Band band,
  ) {
    final coords = _x[diente.numeroFdi]!;
    final gm = <Offset>[];
    final pd = <Offset>[];
    for (final entry in _orderedSites(diente.numeroFdi, band.isOral)) {
      final sitio = diente.sitio(entry.site);
      final x = switch (entry.kind) {
        _PointKind.mesial => band.isOral ? coords.oralMesial : coords.mb,
        _PointKind.center =>
          band.isOral
              ? (coords.oralMesial + coords.oralDistal) / 2
              : (coords.mb + coords.db) / 2,
        _PointKind.distal => band.isOral ? coords.oralDistal : coords.db,
      };
      final gmY =
          band.top +
          band.zeroLine +
          sitio.margenGingivalMm * _scale * band.gmDirection;
      final pdY = gmY + sitio.profundidadSondajeMm * _scale * band.pdDirection;
      gm.add(Offset(x, gmY));
      pd.add(Offset(x, pdY));
    }
    return (gm, pd);
  }

  List<_SiteOrder> _orderedSites(int tooth, bool oral) {
    final isRight =
        (tooth >= 11 && tooth <= 18) || (tooth >= 41 && tooth <= 48);
    final mesial = oral
        ? PeriodontogramaSitioTipo.mesioPalatino
        : PeriodontogramaSitioTipo.mesioVestibular;
    final center = oral
        ? PeriodontogramaSitioTipo.palatino
        : PeriodontogramaSitioTipo.vestibular;
    final distal = oral
        ? PeriodontogramaSitioTipo.distoPalatino
        : PeriodontogramaSitioTipo.distoVestibular;
    return isRight
        ? [
            _SiteOrder(distal, _PointKind.distal),
            _SiteOrder(center, _PointKind.center),
            _SiteOrder(mesial, _PointKind.mesial),
          ]
        : [
            _SiteOrder(mesial, _PointKind.mesial),
            _SiteOrder(center, _PointKind.center),
            _SiteOrder(distal, _PointKind.distal),
          ];
  }

  void _drawSegments(Canvas canvas, List<List<Offset>> segments, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final segment in segments) {
      if (segment.length < 2) {
        continue;
      }
      final path = Path()..moveTo(segment.first.dx, segment.first.dy);
      for (final point in segment.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PeriodontalChartPainter oldDelegate) {
    return oldDelegate.periodontograma != periodontograma;
  }
}

class _Band {
  const _Band({
    required this.top,
    required this.zeroLine,
    required this.isOral,
    required this.gmDirection,
    required this.pdDirection,
    required this.gridDirection,
  });

  const _Band.upperBuccal()
    : this(
        top: 0,
        zeroLine: 106,
        isOral: false,
        gmDirection: 1,
        pdDirection: -1,
        gridDirection: -1,
      );
  const _Band.upperPalatal()
    : this(
        top: 176,
        zeroLine: 53,
        isOral: true,
        gmDirection: -1,
        pdDirection: 1,
        gridDirection: 1,
      );
  const _Band.lowerLingual()
    : this(
        top: 382,
        zeroLine: 108,
        isOral: true,
        gmDirection: 1,
        pdDirection: -1,
        gridDirection: -1,
      );
  const _Band.lowerBuccal()
    : this(
        top: 558,
        zeroLine: 61,
        isOral: false,
        gmDirection: -1,
        pdDirection: 1,
        gridDirection: 1,
      );

  final double top;
  final double zeroLine;
  final bool isOral;
  final double gmDirection;
  final double pdDirection;
  final double gridDirection;
}

class _ToothX {
  const _ToothX({
    required this.mb,
    required this.db,
    this.mp,
    this.dp,
    this.ml,
    this.dl,
  });

  final double mb;
  final double db;
  final double? mp;
  final double? dp;
  final double? ml;
  final double? dl;

  double get oralMesial => mp ?? ml ?? mb;
  double get oralDistal => dp ?? dl ?? db;
}

class _SiteOrder {
  const _SiteOrder(this.site, this.kind);

  final String site;
  final _PointKind kind;
}

enum _PointKind { mesial, center, distal }
