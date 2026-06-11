import 'package:flutter/material.dart';
import 'package:odontologia_app/models/radiografia.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class RadiografiaCard extends StatelessWidget {
  const RadiografiaCard({
    required this.radiografia,
    required this.onEdit,
    required this.onReplaceImage,
    required this.onDelete,
    super.key,
  });

  final Radiografia radiografia;
  final VoidCallback onEdit;
  final VoidCallback onReplaceImage;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  radiografia.imagenUrl,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 88,
                    height: 88,
                    color: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      radiografia.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.inverted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      radiografia.resumen,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      radiografia.fechaEstudioFormateada,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (radiografia.diagnosticoRadiografico?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              radiografia.diagnosticoRadiografico!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.secondary),
            ),
          ],
          if (radiografia.perdidaOseaObservada) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(
                  label:
                      'Perdida osea ${_enumLabel(radiografia.severidadPerdidaOsea)}',
                ),
                if (radiografia.porcentajePerdidaOseaEstimado != null)
                  _Badge(
                    label:
                        '${radiografia.porcentajePerdidaOseaEstimado!.toStringAsFixed(1)}%',
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionChipButton(
                icon: Icons.edit_outlined,
                label: 'Editar',
                onTap: onEdit,
              ),
              _ActionChipButton(
                icon: Icons.image_outlined,
                label: 'Imagen',
                onTap: onReplaceImage,
              ),
              _ActionChipButton(
                icon: Icons.delete_outline_rounded,
                label: 'Eliminar',
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      backgroundColor: Colors.white,
    );
  }
}

String _enumLabel(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  return value.toLowerCase().replaceAll('_', ' ');
}
