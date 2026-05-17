import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class FichaHistorySection extends StatelessWidget {
  const FichaHistorySection({
    required this.onOpenOdontograma,
    required this.onOpenPeriodontograma,
    super.key,
  });

  final VoidCallback onOpenOdontograma;
  final VoidCallback onOpenPeriodontograma;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Historial clinico',
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.inverted,
                  fontSize: 22,
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () {},
              tooltip: 'Nueva ficha',
              icon: const Icon(Icons.add_rounded),
              color: AppColors.primary,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FichaCard(
          onOpenOdontograma: onOpenOdontograma,
          onOpenPeriodontograma: onOpenPeriodontograma,
        ),
      ],
    );
  }
}

class _FichaCard extends StatelessWidget {
  const _FichaCard({
    required this.onOpenOdontograma,
    required this.onOpenPeriodontograma,
  });

  final VoidCallback onOpenOdontograma;
  final VoidCallback onOpenPeriodontograma;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.fileMedical,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ficha actual',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Sin datos clinicos registrados',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FichaAction(
                icon: FontAwesomeIcons.tooth,
                label: 'Odontograma',
                onTap: onOpenOdontograma,
              ),
              _FichaAction(
                icon: FontAwesomeIcons.chartSimple,
                label: 'Periodontograma',
                onTap: onOpenPeriodontograma,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'Activa',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF00786B),
          fontSize: 11,
        ),
      ),
    );
  }
}

class _FichaAction extends StatelessWidget {
  const _FichaAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final FaIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: FaIcon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
