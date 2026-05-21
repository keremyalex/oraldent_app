import 'package:flutter/material.dart';
import 'package:odontologia_app/models/odontograma.dart';
import 'package:odontologia_app/screens/odontograma/widgets/tooth_diagram.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class OdontogramaQuadrantSection extends StatelessWidget {
  const OdontogramaQuadrantSection({
    required this.title,
    required this.subtitle,
    required this.numbers,
    required this.odontograma,
    required this.onDienteTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<int> numbers;
  final Odontograma odontograma;
  final ValueChanged<OdontogramaDiente> onDienteTap;

  @override
  Widget build(BuildContext context) {
    final closestToCenter = numbers.reduce(
      (current, next) => current % 10 < next % 10 ? current : next,
    );

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$closestToCenter cerca del centro',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final number in numbers)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _ToothTile(
                      diente: odontograma.dientePorFdi(number),
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

class _ToothTile extends StatelessWidget {
  const _ToothTile({
    required this.diente,
    required this.numeroFdi,
    required this.onTap,
  });

  final OdontogramaDiente? diente;
  final int numeroFdi;
  final ValueChanged<OdontogramaDiente> onTap;

  @override
  Widget build(BuildContext context) {
    final current = diente;
    final disabled = current == null;
    final borderColor = current?.tieneHallazgos == true
        ? AppColors.primary
        : const Color(0xFFCBD5E1);

    return SizedBox(
      width: 72,
      height: 104,
      child: Material(
        color: disabled ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : () => onTap(current),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Text(
                    '$numeroFdi',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.inverted,
                      fontSize: 12,
                      height: 1,
                    ),
                  ),
                ),
                Positioned.fill(
                  top: 18,
                  bottom: 18,
                  child: current == null
                      ? const SizedBox.shrink()
                      : ToothDiagram(diente: current),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(child: _ToothStatusIcon(diente: current)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToothStatusIcon extends StatelessWidget {
  const _ToothStatusIcon({required this.diente});

  final OdontogramaDiente? diente;

  @override
  Widget build(BuildContext context) {
    if (diente?.ausente == true) {
      return const Icon(Icons.close_rounded, size: 15, color: Colors.red);
    }
    if (diente?.implante == true) {
      return const Icon(
        Icons.add_circle_outline_rounded,
        size: 15,
        color: AppColors.primary,
      );
    }
    return const SizedBox(width: 15, height: 15);
  }
}
