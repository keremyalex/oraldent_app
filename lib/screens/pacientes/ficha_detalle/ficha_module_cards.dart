import 'package:flutter/material.dart';
import 'package:odontologia_app/screens/pacientes/ficha_detalle/ficha_tab_bar.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class FichaModuleEntryCard extends StatelessWidget {
  const FichaModuleEntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryTap,
    super.key,
  });

  final Object icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final String? secondaryActionLabel;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClinicalIcon(
                  icon: icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.inverted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onSecondaryTap != null &&
                      secondaryActionIcon != null &&
                      secondaryActionLabel != null) ...[
                    Tooltip(
                      message: secondaryActionLabel!,
                      child: IconButton.outlined(
                        onPressed: onSecondaryTap,
                        icon: Icon(secondaryActionIcon),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Tooltip(
                    message: actionLabel,
                    child: IconButton.filled(
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
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

class FichaComingSoonCard extends StatelessWidget {
  const FichaComingSoonCard({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final Object icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClinicalIcon(icon: icon, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.inverted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
