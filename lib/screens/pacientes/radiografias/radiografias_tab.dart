import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odontologia_app/models/radiografia.dart';
import 'package:odontologia_app/providers/radiografias_provider.dart';
import 'package:odontologia_app/screens/pacientes/radiografias/image_source_sheet.dart';
import 'package:odontologia_app/screens/pacientes/radiografias/radiografia_card.dart';
import 'package:odontologia_app/screens/pacientes/radiografias/radiografia_form_sheet.dart';
import 'package:odontologia_app/screens/pacientes/radiografias/radiografia_message_card.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class RadiografiasTab extends StatefulWidget {
  const RadiografiasTab({required this.fichaId, super.key});

  final int fichaId;

  @override
  State<RadiografiasTab> createState() => _RadiografiasTabState();
}

class _RadiografiasTabState extends State<RadiografiasTab> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RadiografiasProvider>().loadIfNeeded(widget.fichaId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RadiografiasProvider>();
    final radiografias = provider.radiografiasDeFicha(widget.fichaId);
    final isLoading = provider.cargandoFicha(widget.fichaId);
    final error = provider.errorDeFicha(widget.fichaId);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Radiografias',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.inverted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton.filled(
              onPressed: provider.isSaving ? null : () => _openForm(context),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              tooltip: 'Nueva radiografia',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading && radiografias.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null && radiografias.isEmpty)
          RadiografiaMessageCard(
            icon: Icons.cloud_off_rounded,
            title: 'No se pudieron cargar las radiografias',
            message: error,
            actionLabel: 'Reintentar',
            onAction: () =>
                context.read<RadiografiasProvider>().load(widget.fichaId),
          )
        else if (radiografias.isEmpty)
          RadiografiaMessageCard(
            icon: Icons.image_search_outlined,
            title: 'Sin radiografias',
            message: 'Sube una radiografia periapical o panoramica.',
            actionLabel: 'Subir radiografia',
            onAction: provider.isSaving ? null : () => _openForm(context),
          )
        else
          ...radiografias.map(
            (radiografia) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RadiografiaCard(
                radiografia: radiografia,
                onEdit: () => _openForm(context, radiografia: radiografia),
                onReplaceImage: () => _replaceImage(context, radiografia),
                onDelete: () => _confirmDelete(context, radiografia),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openForm(
    BuildContext context, {
    Radiografia? radiografia,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: context.read<RadiografiasProvider>(),
          child: RadiografiaFormSheet(
            fichaId: widget.fichaId,
            radiografia: radiografia,
          ),
        );
      },
    );
  }

  Future<void> _replaceImage(
    BuildContext context,
    Radiografia radiografia,
  ) async {
    final source = await chooseImageSource(context);
    if (source == null || !context.mounted) {
      return;
    }
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
    );
    if (file == null || !context.mounted) {
      return;
    }
    final message = await context.read<RadiografiasProvider>().reemplazarImagen(
      radiografia: radiografia,
      filePath: file.path,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Imagen actualizada.'),
        backgroundColor: message == null ? AppColors.primary : Colors.red,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Radiografia radiografia,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar radiografia'),
        content: const Text('La radiografia dejara de aparecer en esta ficha.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }
    final message = await context.read<RadiografiasProvider>().desactivar(
      radiografia,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Radiografia eliminada.'),
        backgroundColor: message == null ? AppColors.primary : Colors.red,
      ),
    );
  }
}
