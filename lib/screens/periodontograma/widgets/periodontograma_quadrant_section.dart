import 'package:flutter/material.dart';
import 'package:odontologia_app/models/periodontograma.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class PeriodontogramaQuadrantSection extends StatelessWidget {
  const PeriodontogramaQuadrantSection({
    required this.title,
    required this.subtitle,
    required this.numbers,
    required this.tabla,
    required this.periodontograma,
    required this.onDienteTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<int> numbers;
  final int tabla;
  final Periodontograma periodontograma;
  final ValueChanged<PeriodontogramaDiente> onDienteTap;

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
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.inverted,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final number in numbers)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _PeriodontalToothTile(
                      tabla: tabla,
                      diente: periodontograma.dientePorFdi(number),
                      numeroFdi: number,
                      onTap: onDienteTap,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodontalToothTile extends StatelessWidget {
  const _PeriodontalToothTile({
    required this.tabla,
    required this.diente,
    required this.numeroFdi,
    required this.onTap,
  });

  final int tabla;
  final PeriodontogramaDiente? diente;
  final int numeroFdi;
  final ValueChanged<PeriodontogramaDiente> onTap;

  @override
  Widget build(BuildContext context) {
    final current = diente;
    final asset = _assetPath(
      tabla,
      numeroFdi,
      ausente: current?.ausente == true,
      implante: current?.implante == true,
    );
    return SizedBox(
      width: 84,
      height: 154,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: current == null ? null : () => onTap(current),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: current?.tieneHallazgos == true
                    ? AppColors.primary
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$numeroFdi',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.inverted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.secondary,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                _StatusDots(diente: current),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _assetPath(
    int tabla,
    int numeroFdi, {
    required bool ausente,
    required bool implante,
  }) {
    final direction = numeroFdi >= 30 ? 'abajo' : 'arriba';
    if (ausente) {
      return 'assets/periodontogram/img/tabla$tabla/tachados/periodontograma-dientes-$direction-tachados-$numeroFdi.png';
    }
    if (implante) {
      return 'assets/periodontogram/img/tabla$tabla/implantes/periodontograma-dientes-$direction-tornillo-$numeroFdi.png';
    }
    return 'assets/periodontogram/img/tabla$tabla/periodontograma-dientes-$direction-$numeroFdi.png';
  }
}

class _StatusDots extends StatelessWidget {
  const _StatusDots({required this.diente});

  final PeriodontogramaDiente? diente;

  @override
  Widget build(BuildContext context) {
    final current = diente;
    if (current == null) {
      return const SizedBox(height: 12);
    }
    final dots = <Color>[
      if (current.ausente) Colors.red,
      if (current.implante) AppColors.primary,
      if (current.sitios.any((sitio) => sitio.sangradoSondaje))
        const Color(0xFFDC2626),
      if (current.sitios.any((sitio) => sitio.supuracion))
        const Color(0xFFF59E0B),
    ];
    if (dots.isEmpty) {
      return const SizedBox(height: 12);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final color in dots.take(4))
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
      ],
    );
  }
}
