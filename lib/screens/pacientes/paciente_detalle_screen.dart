import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/providers/fichas_provider.dart';
import 'package:odontologia_app/providers/pacientes_provider.dart';
import 'package:odontologia_app/screens/pacientes/widgets/ficha_history_section.dart';
import 'package:odontologia_app/screens/pacientes/widgets/paciente_detail_card.dart';
import 'package:odontologia_app/screens/pacientes/widgets/paciente_form_sheet.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class PacienteDetalleScreen extends StatefulWidget {
  const PacienteDetalleScreen({
    required this.pacienteId,
    this.paciente,
    super.key,
  });

  final int pacienteId;
  final Paciente? paciente;

  @override
  State<PacienteDetalleScreen> createState() => _PacienteDetalleScreenState();
}

class _PacienteDetalleScreenState extends State<PacienteDetalleScreen> {
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
        context.read<PacientesProvider>().loadIfNeeded();
        context.read<FichasProvider>().loadIfNeeded(widget.pacienteId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PacientesProvider>();
    final fichasProvider = context.watch<FichasProvider>();
    final paciente = _resolvePaciente(provider);

    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 24, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Paciente',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (paciente == null && provider.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (paciente == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No se encontro el paciente.',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: PacienteDetailCard(
                    paciente: paciente,
                    onEdit: () => _openPacienteForm(context, paciente),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: FichaHistorySection(
                    fichas: fichasProvider.fichas,
                    isLoading: fichasProvider.isLoading,
                    isSaving: fichasProvider.isSaving,
                    errorMessage: fichasProvider.errorMessage,
                    onRefresh: () =>
                        context.read<FichasProvider>().load(paciente.id),
                    onCreateFicha: () => _createFicha(context, paciente),
                    onOpenFicha: (ficha) =>
                        _openFichaDetalle(context, paciente, ficha.id),
                    onOpenOdontograma: (ficha) =>
                        _openFichaOdontograma(context, paciente, ficha.id),
                    onOpenPeriodontograma: (ficha) =>
                        _openFichaPeriodontograma(context, paciente, ficha.id),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Paciente? _resolvePaciente(PacientesProvider provider) {
    for (final paciente in provider.pacientes) {
      if (paciente.id == widget.pacienteId) {
        return paciente;
      }
    }
    return widget.paciente;
  }

  Future<void> _openPacienteForm(
    BuildContext context,
    Paciente paciente,
  ) async {
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
          value: context.read<PacientesProvider>(),
          child: PacienteFormSheet(paciente: paciente),
        );
      },
    );
  }

  Future<void> _createFicha(BuildContext context, Paciente paciente) async {
    final message = await context.read<FichasProvider>().crearFichaInicial(
      paciente.id,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Ficha clinica creada.'),
        backgroundColor: message == null ? AppColors.primary : Colors.red,
      ),
    );
  }

  Future<void> _openFichaOdontograma(
    BuildContext context,
    Paciente paciente,
    int fichaId,
  ) async {
    await context.push('/fichas/$fichaId/odontograma', extra: paciente);
    if (!context.mounted) {
      return;
    }
    await context.read<FichasProvider>().load(paciente.id);
  }

  Future<void> _openFichaDetalle(
    BuildContext context,
    Paciente paciente,
    int fichaId,
  ) async {
    await context.push('/fichas/$fichaId', extra: paciente);
    if (!context.mounted) {
      return;
    }
    await context.read<FichasProvider>().load(paciente.id);
  }

  Future<void> _openFichaPeriodontograma(
    BuildContext context,
    Paciente paciente,
    int fichaId,
  ) async {
    await context.push('/fichas/$fichaId/periodontograma', extra: paciente);
    if (!context.mounted) {
      return;
    }
    await context.read<FichasProvider>().load(paciente.id);
  }
}
