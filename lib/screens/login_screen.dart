import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filledTonal(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.primary,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: const Size(44, 44),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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
                    const SizedBox(height: 34),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _FieldLabel(
                            label: 'Correo o celular',
                            child: TextField(
                              controller: _identifierController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'admin@oraldent.com',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _FieldLabel(
                            label: 'Contrasena',
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: '********',
                                prefixIcon:
                                    const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Olvide mi contrasena'),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 50,
                            child: FilledButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () => _submitLogin(context),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Iniciar sesion'),
                            ),
                          ),
                          if (authProvider.errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              authProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
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
      context.go('/dashboard');
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.inverted,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
