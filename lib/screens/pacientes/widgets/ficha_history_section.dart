import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:odontologia_app/models/ficha_clinica.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class FichaHistorySection extends StatelessWidget {
  const FichaHistorySection({
    required this.fichas,
    required this.isLoading,
    required this.isSaving,
    required this.onRefresh,
    required this.onCreateFicha,
    required this.onOpenFicha,
    required this.onOpenOdontograma,
    required this.onOpenPeriodontograma,
    this.errorMessage,
    super.key,
  });

  final List<FichaClinica> fichas;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onCreateFicha;
  final ValueChanged<FichaClinica> onOpenFicha;
  final ValueChanged<FichaClinica> onOpenOdontograma;
  final ValueChanged<FichaClinica> onOpenPeriodontograma;

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
              onPressed: isSaving ? null : onCreateFicha,
              tooltip: 'Nueva ficha',
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_rounded),
              color: AppColors.primary,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading && fichas.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (errorMessage != null && fichas.isEmpty)
          _FichaMessage(
            icon: Icons.cloud_off_rounded,
            title: 'No se pudieron cargar las fichas',
            message: errorMessage!,
            actionLabel: 'Reintentar',
            onAction: onRefresh,
          )
        else if (fichas.isEmpty)
          _FichaMessage(
            icon: Icons.description_outlined,
            title: 'Sin fichas clinicas',
            message: 'Crea una ficha para registrar la consulta del paciente.',
            actionLabel: 'Crear ficha',
            onAction: isSaving ? null : onCreateFicha,
          )
        else
          ...fichas.map(
            (ficha) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FichaCard(
                ficha: ficha,
                onOpenFicha: () => onOpenFicha(ficha),
                onOpenOdontograma: () => onOpenOdontograma(ficha),
                onOpenPeriodontograma: () => onOpenPeriodontograma(ficha),
              ),
            ),
          ),
      ],
    );
  }
}

class _FichaCard extends StatelessWidget {
  const _FichaCard({
    required this.ficha,
    required this.onOpenFicha,
    required this.onOpenOdontograma,
    required this.onOpenPeriodontograma,
  });

  final FichaClinica ficha;
  final VoidCallback onOpenFicha;
  final VoidCallback onOpenOdontograma;
  final VoidCallback onOpenPeriodontograma;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpenFicha,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                          ficha.titulo,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.inverted,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          ficha.fechaFormateada,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          ficha.tieneDatosClinicos
                              ? ficha.motivoConsulta ??
                                    'Datos clinicos registrados'
                              : 'Sin datos clinicos registrados',
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
        ),
      ),
    );
  }
}

class _FichaMessage extends StatelessWidget {
  const _FichaMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.inverted,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
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
