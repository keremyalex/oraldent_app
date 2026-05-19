import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/models/periodontograma.dart';
import 'package:odontologia_app/providers/periodontograma_provider.dart';
import 'package:odontologia_app/screens/periodontograma/widgets/periodontograma_chart_section.dart';
import 'package:odontologia_app/screens/periodontograma/widgets/periodontograma_diente_sheet.dart';
import 'package:odontologia_app/screens/periodontograma/widgets/periodontograma_message.dart';
import 'package:odontologia_app/screens/periodontograma/widgets/periodontograma_quadrant_section.dart';
import 'package:odontologia_app/screens/periodontograma/widgets/periodontograma_summary_band.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class PeriodontogramaScreen extends StatefulWidget {
  const PeriodontogramaScreen({
    required this.pacienteId,
    this.fichaId,
    this.paciente,
    super.key,
  });

  final int pacienteId;
  final int? fichaId;
  final Paciente? paciente;

  @override
  State<PeriodontogramaScreen> createState() => _PeriodontogramaScreenState();
}

class _PeriodontogramaScreenState extends State<PeriodontogramaScreen> {
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
        _loadPeriodontograma(context);
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
    final provider = context.watch<PeriodontogramaProvider>();
    final periodontograma = provider.periodontograma;
    final paciente = widget.paciente ?? periodontograma?.paciente;
    final currentObservaciones = periodontograma?.observaciones ?? '';
    if (_lastObservaciones != currentObservaciones) {
      _lastObservaciones = currentObservaciones;
      _observacionesController.text = currentObservaciones;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goBack(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutral,
        appBar: _PeriodontogramaAppBar(
          paciente: paciente,
          isLoading: provider.isLoading,
          onBack: () => _goBack(context),
          onRefresh: () => _loadPeriodontograma(context),
        ),
        body: SafeArea(
          child: _PeriodontogramaBody(
            provider: provider,
            observacionesController: _observacionesController,
            onOpenDiente: _openDienteSheet,
            onSaveObservaciones: () => _saveObservaciones(context),
            onRetry: () => _loadPeriodontograma(context),
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

  void _loadPeriodontograma(BuildContext context) {
    final fichaId = widget.fichaId;
    if (fichaId == null) {
      context.read<PeriodontogramaProvider>().load(widget.pacienteId);
      return;
    }
    context.read<PeriodontogramaProvider>().loadPorFicha(fichaId);
  }

  Future<void> _saveObservaciones(BuildContext context) async {
    final message = await context
        .read<PeriodontogramaProvider>()
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

  Future<void> _openDienteSheet(PeriodontogramaDiente diente) async {
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
          value: context.read<PeriodontogramaProvider>(),
          child: PeriodontogramaDienteSheet(diente: diente),
        );
      },
    );
  }
}

class _PeriodontogramaAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _PeriodontogramaAppBar({
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
              'Periodontograma',
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

class _PeriodontogramaBody extends StatelessWidget {
  const _PeriodontogramaBody({
    required this.provider,
    required this.observacionesController,
    required this.onOpenDiente,
    required this.onSaveObservaciones,
    required this.onRetry,
  });

  final PeriodontogramaProvider provider;
  final TextEditingController observacionesController;
  final ValueChanged<PeriodontogramaDiente> onOpenDiente;
  final VoidCallback onSaveObservaciones;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final periodontograma = provider.periodontograma;
    if (provider.isLoading && periodontograma == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null && periodontograma == null) {
      return PeriodontogramaMessage(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudo cargar el periodontograma',
        message: provider.errorMessage!,
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    }
    if (periodontograma == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      children: [
        PeriodontogramaSummaryBand(periodontograma: periodontograma),
        const SizedBox(height: 16),
        PeriodontogramaChartSection(periodontograma: periodontograma),
        const SizedBox(height: 16),
        PeriodontogramaQuadrantSection(
          title: 'Cuadrante 1',
          subtitle: 'Superior derecho',
          numbers: const [18, 17, 16, 15, 14, 13, 12, 11],
          tabla: 1,
          periodontograma: periodontograma,
          onDienteTap: onOpenDiente,
        ),
        const SizedBox(height: 14),
        PeriodontogramaQuadrantSection(
          title: 'Cuadrante 2',
          subtitle: 'Superior izquierdo',
          numbers: const [21, 22, 23, 24, 25, 26, 27, 28],
          tabla: 2,
          periodontograma: periodontograma,
          onDienteTap: onOpenDiente,
        ),
        const SizedBox(height: 14),
        PeriodontogramaQuadrantSection(
          title: 'Cuadrante 4',
          subtitle: 'Inferior derecho',
          numbers: const [48, 47, 46, 45, 44, 43, 42, 41],
          tabla: 5,
          periodontograma: periodontograma,
          onDienteTap: onOpenDiente,
        ),
        const SizedBox(height: 14),
        PeriodontogramaQuadrantSection(
          title: 'Cuadrante 3',
          subtitle: 'Inferior izquierdo',
          numbers: const [31, 32, 33, 34, 35, 36, 37, 38],
          tabla: 6,
          periodontograma: periodontograma,
          onDienteTap: onOpenDiente,
        ),
        const SizedBox(height: 18),
        TextField(
          controller: observacionesController,
          minLines: 3,
          maxLines: 5,
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
