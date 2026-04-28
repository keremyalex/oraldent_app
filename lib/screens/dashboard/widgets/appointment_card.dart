import 'package:flutter/material.dart';
import 'package:odontologia_app/models/cita.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    required this.cita,
    super.key,
  });

  final Cita cita;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _statusColor(cita.estado);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  cita.paciente.initials,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cita.paciente.nombreCompleto,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.inverted,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cita.tituloServicio,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  cita.hora,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.inverted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    _statusLabel(cita.estado),
                    style: textTheme.labelLarge?.copyWith(
                      color: color,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
