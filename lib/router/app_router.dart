import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/screens/citas/citas_screen.dart';
import 'package:odontologia_app/screens/dashboard/dashboard_screen.dart';
import 'package:odontologia_app/screens/home/home_screen.dart';
import 'package:odontologia_app/screens/login/login_screen.dart';
import 'package:odontologia_app/screens/pacientes/pacientes_screen.dart';
import 'package:odontologia_app/screens/settings/schedule_settings_screen.dart';
import 'package:odontologia_app/screens/settings/services_settings_screen.dart';
import 'package:odontologia_app/screens/settings/settings_screen.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: authProvider,
    redirect: (context, state) {
      if (authProvider.isRestoring) {
        return '/splash';
      }

      final location = state.matchedLocation;
      final publicRoutes = {'/splash', '/home', '/login'};
      final isPublicRoute = publicRoutes.contains(location);

      if (authProvider.isAuthenticated && isPublicRoute) {
        return '/citas';
      }

      if (!authProvider.isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/citas',
        builder: (context, state) => const CitasScreen(),
      ),
      GoRoute(
        path: '/pacientes',
        builder: (context, state) => const PacientesScreen(),
      ),
      GoRoute(
        path: '/ajustes',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/ajustes/horarios',
        builder: (context, state) => const ScheduleSettingsScreen(),
      ),
      GoRoute(
        path: '/ajustes/servicios',
        builder: (context, state) => const ServicesSettingsScreen(),
      ),
    ],
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
