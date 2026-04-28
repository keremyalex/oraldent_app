import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class CitasHeader extends StatelessWidget {
  const CitasHeader({
    required this.userRole,
    super.key,
  });

  final String userRole;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Citas',
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 32,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Agenda odontologica - $userRole',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.home_rounded),
          color: AppColors.primary,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            fixedSize: const Size(48, 48),
          ),
        ),
      ],
    );
  }
}
