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
  const OdontogramaScreen({required this.pacienteId, this.paciente, super.key});

  final int pacienteId;
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
        context.read<OdontogramaProvider>().load(widget.pacienteId);
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
          onBack: () => _goBack(context),
          onRefresh: () =>
              context.read<OdontogramaProvider>().load(widget.pacienteId),
        ),
        body: SafeArea(
          child: _OdontogramaBody(
            pacienteId: widget.pacienteId,
            provider: provider,
            observacionesController: _observacionesController,
            onOpenDiente: _openDienteSheet,
            onSaveObservaciones: () => _saveObservaciones(context),
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

  Future<void> _saveObservaciones(BuildContext context) async {
    final message = await context
        .read<OdontogramaProvider>()
        .actualizarObservaciones(_observacionesController.text);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Observaciones guardadas.'),
        backgroundColor: message == null ? AppColors.primary : Colors.red,
      ),
    );
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
          child: DienteSheet(diente: diente),
        );
      },
    );
  }
}

class _OdontogramaAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _OdontogramaAppBar({
    required this.isLoading,
    required this.onBack,
    required this.onRefresh,
    this.paciente,
  });

  final Paciente? paciente;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

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
      ],
    );
  }
}

class _OdontogramaBody extends StatelessWidget {
  const _OdontogramaBody({
    required this.pacienteId,
    required this.provider,
    required this.observacionesController,
    required this.onOpenDiente,
    required this.onSaveObservaciones,
  });

  final int pacienteId;
  final OdontogramaProvider provider;
  final TextEditingController observacionesController;
  final ValueChanged<OdontogramaDiente> onOpenDiente;
  final VoidCallback onSaveObservaciones;

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
        onAction: () => context.read<OdontogramaProvider>().load(pacienteId),
      );
    }

    if (odontograma == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      children: [
        OdontogramaSummaryBand(odontograma: odontograma),
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
          minLines: 3,
          maxLines: 5,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            labelText: 'Observaciones generales',
            prefixIcon: Icon(Icons.notes_rounded),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: provider.isSaving ? null : onSaveObservaciones,
          icon: provider.isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: const Text('Guardar observaciones'),
        ),
      ],
    );
  }
}
