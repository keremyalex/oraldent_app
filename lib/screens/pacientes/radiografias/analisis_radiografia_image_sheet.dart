import 'package:flutter/material.dart';
import 'package:odontologia_app/models/analisis_radiografia.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class AnalisisRadiografiaImageSheet extends StatelessWidget {
  const AnalisisRadiografiaImageSheet({required this.analisis, super.key});

  final AnalisisRadiografia analisis;

  @override
  Widget build(BuildContext context) {
    final overlay = analisis.overlayBytes;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Imagen analizada por IA',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.inverted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Las marcas son una ayuda automatica y requieren validacion clinica.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 14),
            if (overlay == null)
              const _UnavailableImage()
            else
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.62,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.memory(
                      overlay,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const _UnavailableImage(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableImage extends StatelessWidget {
  const _UnavailableImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hide_image_outlined, color: AppColors.secondary),
          SizedBox(height: 8),
          Text('No hay una imagen anotada disponible para este analisis.'),
        ],
      ),
    );
  }
}
