import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/odontograma.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/providers/odontograma_provider.dart';
import 'package:odontologia_app/screens/odontograma/widgets/diente_sheet.dart';
import 'package:odontologia_app/screens/odontograma/widgets/odontograma_message.dart';
import 'package:odontologia_app/screens/odontograma/widgets/odontograma_quadrant_section.dart';
import 'package:odontologia_app/screens/odontograma/widgets/odontograma_summary_band.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class OdontogramaScreen extends StatefulWidget {
  const OdontogramaScreen({required this.fichaId, this.paciente, super.key});

  final int fichaId;
  final Paciente? paciente;

  @override
  State<OdontogramaScreen> createState() => _OdontogramaScreenState();
}

class _OdontogramaScreenState extends State<OdontogramaScreen> {
  final _observacionesController = TextEditingController();
  bool _loaded = false;
  String? _lastObservaciones;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadOdontograma(context);
      }
    });
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OdontogramaProvider>();
    final odontograma = provider.odontograma;
    final paciente = widget.paciente ?? odontograma?.paciente;

    final currentObservaciones = odontograma?.observaciones ?? '';
    if (_lastObservaciones != currentObservaciones) {
      _lastObservaciones = currentObservaciones;
      _observacionesController.text = currentObservaciones;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _goBack(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral,
        appBar: _OdontogramaAppBar(
          paciente: paciente,
          isLoading: provider.isLoading,
          isEditing: provider.isEditing,
          onBack: () => _goBack(context),
          onRefresh: () => _loadOdontograma(context),
          onEdit: () => context.read<OdontogramaProvider>().startEditing(),
        ),
        body: SafeArea(
          child: _OdontogramaBody(
            provider: provider,
            observacionesController: _observacionesController,
            onOpenDiente: _openDienteSheet,
            onSaveObservaciones: () => _saveObservaciones(context),
            onSaveOdontograma: () => _saveOdontograma(context),
            onCancelEditing: () => _cancelEditing(context),
            onRetry: () => _loadOdontograma(context),
          ),
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/pacientes');
  }

  void _loadOdontograma(BuildContext context) {
    context.read<OdontogramaProvider>().loadPorFicha(widget.fichaId);
  }

  void _saveObservaciones(BuildContext context) {
    _saveOdontograma(context);
  }

  Future<void> _saveOdontograma(BuildContext context) async {
    final message = await context
        .read<OdontogramaProvider>()
        .guardarOdontograma(_observacionesController.text);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Odontograma guardado.'),
        backgroundColor: message == null ? AppColors.primary : Colors.red,
      ),
    );
  }

  void _cancelEditing(BuildContext context) {
    context.read<OdontogramaProvider>().discardEditing();
    final odontograma = context.read<OdontogramaProvider>().odontograma;
    _lastObservaciones = odontograma?.observaciones ?? '';
    _observacionesController.text = _lastObservaciones!;
  }

  Future<void> _openDienteSheet(OdontogramaDiente diente) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: context.read<OdontogramaProvider>(),
          child: DienteSheet(
            diente: diente,
            enabled: context.read<OdontogramaProvider>().isEditing,
          ),
        );
      },
    );
  }
}

class _OdontogramaAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _OdontogramaAppBar({
    required this.isLoading,
    required this.isEditing,
    required this.onBack,
    required this.onRefresh,
    required this.onEdit,
    this.paciente,
  });

  final Paciente? paciente;
  final bool isLoading;
  final bool isEditing;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.inverted,
      elevation: 0,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Volver',
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Odontograma',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.inverted,
                fontSize: 17,
              ),
            ),
            if (paciente != null)
              Text(
                paciente!.nombreCompleto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: isLoading ? null : onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Actualizar',
        ),
        IconButton(
          onPressed: isLoading || isEditing ? null : onEdit,
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Editar odontograma',
        ),
      ],
    );
  }
}

class _OdontogramaBody extends StatelessWidget {
  const _OdontogramaBody({
    required this.provider,
    required this.observacionesController,
    required this.onOpenDiente,
    required this.onSaveObservaciones,
    required this.onSaveOdontograma,
    required this.onCancelEditing,
    required this.onRetry,
  });

  final OdontogramaProvider provider;
  final TextEditingController observacionesController;
  final ValueChanged<OdontogramaDiente> onOpenDiente;
  final VoidCallback onSaveObservaciones;
  final VoidCallback onSaveOdontograma;
  final VoidCallback onCancelEditing;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final odontograma = provider.odontograma;

    if (provider.isLoading && odontograma == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && odontograma == null) {
      return OdontogramaMessage(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudo cargar el odontograma',
        message: provider.errorMessage!,
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    }

    if (odontograma == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      children: [
        OdontogramaSummaryBand(odontograma: odontograma),
        if (!provider.isEditing) ...[
          const SizedBox(height: 12),
          _EditHint(onEdit: context.read<OdontogramaProvider>().startEditing),
        ],
        const SizedBox(height: 16),
        OdontogramaQuadrantSection(
          title: 'Cuadrante 1',
          subtitle: 'Superior derecho',
          numbers: const [18, 17, 16, 15, 14, 13, 12, 11],
          odontograma: odontograma,
          onDienteTap: onOpenDiente,
        ),
        const SizedBox(height: 14),
        OdontogramaQuadrantSection(
          title: 'Cuadrante 2',
          subtitle: 'Superior izquierdo',
          numbers: const [21, 22, 23, 24, 25, 26, 27, 28],
          odontograma: odontograma,
          onDienteTap: onOpenDiente,
        ),
        const SizedBox(height: 14),
        OdontogramaQuadrantSection(
          title: 'Cuadrante 4',
          subtitle: 'Inferior derecho',
          numbers: const [48, 47, 46, 45, 44, 43, 42, 41],
          odontograma: odontograma,
          onDienteTap: onOpenDiente,
        ),
        const SizedBox(height: 14),
        OdontogramaQuadrantSection(
          title: 'Cuadrante 3',
          subtitle: 'Inferior izquierdo',
          numbers: const [31, 32, 33, 34, 35, 36, 37, 38],
          odontograma: odontograma,
          onDienteTap: onOpenDiente,
        ),
        const SizedBox(height: 18),
        TextField(
          controller: observacionesController,
          enabled: provider.isEditing,
          minLines: 3,
          maxLines: 5,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            labelText: 'Observaciones generales',
            prefixIcon: Icon(Icons.notes_rounded),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.isSaving || !provider.isEditing
                    ? null
                    : onCancelEditing,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: provider.isSaving || !provider.isEditing
                    ? null
                    : onSaveOdontograma,
                icon: provider.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditHint extends StatelessWidget {
  const _EditHint({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Activa la edicion para modificar piezas y guardar todo al final.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Editar')),
        ],
      ),
    );
  }
}
