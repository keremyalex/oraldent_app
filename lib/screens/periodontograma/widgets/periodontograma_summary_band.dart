import 'package:flutter/material.dart';
import 'package:odontologia_app/models/periodontograma.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class PeriodontogramaSummaryBand extends StatelessWidget {
  const PeriodontogramaSummaryBand({required this.periodontograma, super.key});

  final Periodontograma periodontograma;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _Metric(
            icon: Icons.water_drop_outlined,
            value: '${periodontograma.sitiosConSangrado}',
            label: 'Sangrado',
          ),
          _Metric(
            icon: Icons.grid_view_rounded,
            value: '${periodontograma.sitiosConPlaca}',
            label: 'Placa',
          ),
          _Metric(
            icon: Icons.warning_amber_rounded,
            value: '${periodontograma.sitiosConSupuracion}',
            label: 'Supuracion',
          ),
          _Metric(
            icon: Icons.straighten_rounded,
            value: '${periodontograma.profundidadMaxima} mm',
            label: 'Sondaje max.',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
