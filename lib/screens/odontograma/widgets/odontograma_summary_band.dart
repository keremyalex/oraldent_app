import 'package:flutter/material.dart';
import 'package:odontologia_app/models/odontograma.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class OdontogramaSummaryBand extends StatelessWidget {
  const OdontogramaSummaryBand({required this.odontograma, super.key});

  final Odontograma odontograma;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medical_services_outlined,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${odontograma.hallazgos} piezas con hallazgos',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          const _LegendDot(color: Color(0xFFDC2626), label: 'Rojo'),
          const SizedBox(width: 8),
          const _LegendDot(color: Color(0xFF2563EB), label: 'Azul'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
