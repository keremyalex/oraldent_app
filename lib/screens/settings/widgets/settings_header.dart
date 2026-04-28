import 'package:flutter/material.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    required this.title,
    required this.subtitle,
    this.onHome,
    this.onBack,
    this.onRefresh,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onHome;
  final VoidCallback? onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        if (onBack != null) ...[
          IconButton.filledTonal(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: onBack == null ? 32 : 28,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onHome != null)
          IconButton.filledTonal(
            onPressed: onHome,
            icon: const Icon(Icons.home_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              fixedSize: const Size(48, 48),
            ),
          ),
        if (onRefresh != null)
          IconButton.filledTonal(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
      ],
    );
  }
}
