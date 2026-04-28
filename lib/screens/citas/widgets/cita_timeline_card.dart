import 'package:flutter/material.dart';
import 'package:odontologia_app/models/cita.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class CitaTimelineCard extends StatelessWidget {
  const CitaTimelineCard({
    required this.cita,
    required this.onTap,
    super.key,
  });

  final Cita cita;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _statusColor(cita.estado);
    final duration = cita.fechaHoraFin.difference(cita.fechaHoraInicio);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  cita.hora,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.inverted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'hrs',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.035),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  cita.paciente.nombreCompleto,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: AppColors.inverted,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _StatusChip(
                                label: _statusLabel(cita.estado),
                                color: color,
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            cita.motivo,
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (cita.servicio != null) ...[
                            const SizedBox(height: 8),
                            _InfoPill(
                              icon: Icons.medical_services_outlined,
                              text: cita.servicio!.nombre,
                            ),
                          ],
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _OriginBadge(
                                isApp: cita.registradaDesdeApp,
                              ),
                              _InfoPill(
                                icon: Icons.schedule_rounded,
                                text: '${duration.inMinutes} min',
                              ),
                              _InfoPill(
                                icon: Icons.phone_rounded,
                                text: cita.paciente.celular,
                              ),
                            ],
                          ),
                          if (cita.notas != null && cita.notas!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              cita.notas!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'CONFIRMADA' => AppColors.tertiary,
      'PENDIENTE' => AppColors.primary,
      'REPROGRAMADA' => const Color(0xFF505F76),
      'ATENDIDA' => const Color(0xFF00786B),
      'CANCELADA' || 'NO_ASISTIO' => const Color(0xFFBA1A1A),
      _ => AppColors.primary,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'CONFIRMADA' => 'Confirmada',
      'PENDIENTE' => 'Pendiente',
      'REPROGRAMADA' => 'Reprogramada',
      'ATENDIDA' => 'Atendida',
      'CANCELADA' => 'Cancelada',
      'NO_ASISTIO' => 'No asistio',
      _ => status,
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _OriginBadge extends StatelessWidget {
  const _OriginBadge({
    required this.isApp,
  });

  final bool isApp;

  @override
  Widget build(BuildContext context) {
    final color = isApp ? AppColors.primary : const Color(0xFF7C5800);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApp ? Icons.phone_iphone_rounded : Icons.public_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            isApp ? 'App' : 'Web',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
