import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExitConfirmGuard extends StatelessWidget {
  const ExitConfirmGuard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Salir de la aplicacion'),
              content: const Text('¿Seguro que quieres cerrar OralDent?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Salir'),
                ),
              ],
            );
          },
        );

        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}

class DashboardBackGuard extends StatelessWidget {
  const DashboardBackGuard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        context.go('/dashboard');
      },
      child: child,
    );
  }
}
