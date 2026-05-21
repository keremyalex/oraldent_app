import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class PacienteDetailCard extends StatelessWidget {
  const PacienteDetailCard({
    required this.paciente,
    required this.onEdit,
    super.key,
  });

  final Paciente paciente;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F7F4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PatientAvatar(paciente: paciente),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paciente.nombreCompleto,
                      style: textTheme.displayLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 20,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InlineInfo(
                      icon: FontAwesomeIcons.phone,
                      text: paciente.celular,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onEdit,
                tooltip: 'Editar paciente',
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.primary,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (paciente.documentoIdentidad != null &&
                  paciente.documentoIdentidad!.isNotEmpty)
                _InfoChip(
                  icon: FontAwesomeIcons.idCard,
                  text: paciente.documentoIdentidad!,
                ),
              if (paciente.correo != null && paciente.correo!.isNotEmpty)
                _InfoChip(
                  icon: FontAwesomeIcons.envelope,
                  text: paciente.correo!,
                ),
              if (paciente.direccion != null && paciente.direccion!.isNotEmpty)
                _InfoChip(
                  icon: FontAwesomeIcons.locationDot,
                  text: paciente.direccion!,
                ),
              if (paciente.fechaNacimiento != null)
                _InfoChip(
                  icon: FontAwesomeIcons.cakeCandles,
                  text: _formatDate(paciente.fechaNacimiento!),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _PatientAvatar extends StatelessWidget {
  const _PatientAvatar({required this.paciente});

  final Paciente paciente;

  @override
  Widget build(BuildContext context) {
    final photo = paciente.fotoUrl;

    return Container(
      width: 56,
      height: 56,
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

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.icon, required this.text});

  final FaIconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, size: 13, color: AppColors.secondary),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final FaIconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.56)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12, color: AppColors.secondary),
          const SizedBox(width: 7),
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
      ),
    );
  }
}
