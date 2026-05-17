import 'package:flutter/material.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class PacienteCard extends StatelessWidget {
  const PacienteCard({
    required this.paciente,
    required this.onTap,
    required this.onOdontogramaTap,
    required this.onPeriodontogramaTap,
    super.key,
  });

  final Paciente paciente;
  final VoidCallback onTap;
  final VoidCallback onOdontogramaTap;
  final VoidCallback onPeriodontogramaTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PatientAvatar(paciente: paciente),
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
                            paciente.nombreCompleto,
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.inverted,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const _StatusChip(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          icon: Icons.phone_rounded,
                          text: paciente.celular,
                        ),
                        if (paciente.documentoIdentidad != null &&
                            paciente.documentoIdentidad!.isNotEmpty)
                          _InfoPill(
                            icon: Icons.badge_outlined,
                            text: paciente.documentoIdentidad!,
                          ),
                      ],
                    ),
                    if (paciente.correo != null &&
                        paciente.correo!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _InfoPill(
                        icon: Icons.mail_outline_rounded,
                        text: paciente.correo!,
                      ),
                    ],
                    if (paciente.direccion != null &&
                        paciente.direccion!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _InfoPill(
                        icon: Icons.location_on_outlined,
                        text: paciente.direccion!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                children: [
                  IconButton(
                    onPressed: onOdontogramaTap,
                    tooltip: 'Odontograma',
                    icon: const Icon(Icons.medical_services_outlined),
                    color: AppColors.primary,
                  ),
                  IconButton(
                    onPressed: onPeriodontogramaTap,
                    tooltip: 'Periodontograma',
                    icon: const Icon(Icons.grid_view_rounded),
                    color: AppColors.secondary,
                  ),
                  Icon(
                    Icons.edit_rounded,
                    color: AppColors.secondary.withValues(alpha: 0.7),
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

class _PatientAvatar extends StatelessWidget {
  const _PatientAvatar({required this.paciente});

  final Paciente paciente;

  @override
  Widget build(BuildContext context) {
    final photo = paciente.fotoUrl;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: photo == null || photo.isEmpty
          ? Center(
              child: Text(
                paciente.initials,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : Image.network(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    paciente.initials,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'Activo',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: const Color(0xFF00786B),
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

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
