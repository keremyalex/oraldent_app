import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/screens/login/widgets/login_form_card.dart';
import 'package:odontologia_app/screens/login/widgets/login_header.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical -
                  56,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LoginHeader(
                      onBack: () => context.go('/home'),
                    ),
                    const SizedBox(height: 34),
                    LoginFormCard(
                      identifierController: _identifierController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      isLoading: authProvider.isLoading,
                      errorMessage: authProvider.errorMessage,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      onSubmit: () => _submitLogin(context),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Acceso exclusivo para personal autorizado.',
                      textAlign: TextAlign.center,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitLogin(BuildContext context) async {
    final identificador = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identificador.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa tu correo/celular y contrasena.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await context.read<AuthProvider>().login(
          identificador: identificador,
          password: password,
        );

    if (!context.mounted) {
      return;
    }

    if (success) {
      context.go('/citas');
    }
  }
}
