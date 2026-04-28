import 'package:flutter/material.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class HomeActions extends StatelessWidget {
  const HomeActions({
    required this.onStart,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onStart;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 50,
          child: FilledButton(
            onPressed: onStart,
            child: const Text('Comenzar'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: OutlinedButton(
            onPressed: onLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: textTheme.labelLarge,
            ),
            child: const Text('Iniciar sesion'),
          ),
        ),
      ],
    );
  }
}
