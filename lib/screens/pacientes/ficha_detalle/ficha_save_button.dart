import 'package:flutter/material.dart';

class FichaSaveButton extends StatelessWidget {
  const FichaSaveButton({
    required this.isSaving,
    required this.onPressed,
    super.key,
  });

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: FilledButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded),
        label: const Text('Guardar ficha'),
      ),
    );
  }
}
