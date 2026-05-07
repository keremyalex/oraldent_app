import 'package:flutter/material.dart';
import 'package:odontologia_app/models/odontograma.dart';
import 'package:odontologia_app/screens/odontograma/widgets/tooth_diagram.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class OdontogramaArcadeSection extends StatelessWidget {
  const OdontogramaArcadeSection({
    required this.title,
    required this.firstRow,
    required this.secondRow,
    required this.odontograma,
    required this.onDienteTap,
    super.key,
  });

  final String title;
  final List<int> firstRow;
  final List<int> secondRow;
  final Odontograma odontograma;
  final ValueChanged<OdontogramaDiente> onDienteTap;

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
          const SizedBox(height: 12),
          _ToothRow(
            numbers: firstRow,
            odontograma: odontograma,
            onDienteTap: onDienteTap,
          ),
          const SizedBox(height: 10),
          _ToothRow(
            numbers: secondRow,
            odontograma: odontograma,
            onDienteTap: onDienteTap,
          ),
        ],
      ),
    );
  }
}

class _ToothRow extends StatelessWidget {
  const _ToothRow({
    required this.numbers,
    required this.odontograma,
    required this.onDienteTap,
  });

  final List<int> numbers;
  final Odontograma odontograma;
  final ValueChanged<OdontogramaDiente> onDienteTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final number in numbers)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _ToothTile(
                diente: odontograma.dientePorFdi(number),
                numeroFdi: number,
                onTap: onDienteTap,
              ),
            ),
          ),
      ],
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

    return AspectRatio(
      aspectRatio: 0.68,
      child: Material(
        color: disabled ? const Color(0xFFF1F5F9) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: disabled ? null : () => onTap(current),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(3),
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
                      fontSize: 10,
                      height: 1,
                    ),
                  ),
                ),
                Positioned.fill(
                  top: 12,
                  bottom: 12,
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
      return const Icon(Icons.close_rounded, size: 12, color: Colors.red);
    }
    if (diente?.implante == true) {
      return const Icon(
        Icons.add_circle_outline_rounded,
        size: 12,
        color: AppColors.primary,
      );
    }
    return const SizedBox(width: 12, height: 12);
  }
}
