import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/screens/home/widgets/brand_logo.dart';
import 'package:odontologia_app/screens/home/widgets/home_actions.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BrandLogo(),
                  const SizedBox(height: 44),
                  Text(
                    'OralDent',
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 42,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Excelencia clinica y comodidad para el paciente en un solo lugar. Gestiona citas, pacientes y atencion odontologica con precision.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 72),
                  HomeActions(
                    onStart: () => context.go('/login'),
                    onLogin: () => context.go('/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
