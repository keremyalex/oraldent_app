import 'package:flutter/material.dart';
import 'package:odontologia_app/screens/home/widgets/brand_logo.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    required this.onBack,
    super.key,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton.filledTonal(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.primary,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              fixedSize: const Size(44, 44),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Center(
          child: BrandLogo(size: 92, padding: 8),
        ),
        const SizedBox(height: 32),
        Text(
          'Portal del personal',
          textAlign: TextAlign.center,
          style: textTheme.displayLarge?.copyWith(
            color: AppColors.inverted,
            fontSize: 30,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ingresa tus credenciales para acceder al sistema de gestion odontologica.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.secondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
