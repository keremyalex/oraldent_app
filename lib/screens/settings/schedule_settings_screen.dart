import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/horario_atencion.dart';
import 'package:odontologia_app/providers/horarios_provider.dart';
import 'package:odontologia_app/screens/settings/widgets/horario_day_section.dart';
import 'package:odontologia_app/screens/settings/widgets/horario_form_sheet.dart';
import 'package:odontologia_app/screens/settings/widgets/settings_header.dart';
import 'package:odontologia_app/screens/settings/widgets/settings_message.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:odontologia_app/widgets/app_bottom_navigation.dart';
import 'package:provider/provider.dart';

class ScheduleSettingsScreen extends StatefulWidget {
  const ScheduleSettingsScreen({super.key});

  @override
  State<ScheduleSettingsScreen> createState() => _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState extends State<ScheduleSettingsScreen> {
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
        context.read<HorariosProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final horarios = context.watch<HorariosProvider>();
    final groupedHorarios = _groupHorariosByDay(horarios.horarios);

    return Scaffold(
      backgroundColor: AppColors.neutral,
      bottomNavigationBar: const AppBottomNavigation(
        currentTab: AppTab.settings,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: horarios.isSaving ? null : () => _openHorarioForm(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: SettingsHeader(
                  title: 'Horario de atencion',
                  subtitle: 'Bloques disponibles por dia',
                  onBack: () => context.pop(),
                  onRefresh: horarios.isLoading
                      ? null
                      : () => context.read<HorariosProvider>().load(),
                ),
              ),
            ),
            if (horarios.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (horarios.errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: SettingsMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'No se pudieron cargar los horarios',
                  message: horarios.errorMessage!,
                  actionLabel: 'Reintentar',
                  onAction: () => context.read<HorariosProvider>().load(),
                ),
              )
            else if (horarios.horarios.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: SettingsMessage(
                  icon: Icons.schedule_rounded,
                  title: 'Sin horarios configurados',
                  message: 'Agrega los dias y rangos de atencion de la clinica.',
                  actionLabel: 'Agregar horario',
                  onAction: () => _openHorarioForm(context),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                sliver: SliverList.separated(
                  itemCount: groupedHorarios.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final group = groupedHorarios[index];
                    return HorarioDaySection(
                      dayLabel: group.dayLabel,
                      horarios: group.horarios,
                      onEdit: (horario) => _openHorarioForm(context, horario),
                      onDelete: (horario) => _confirmDelete(context, horario),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_HorarioDayGroup> _groupHorariosByDay(List<HorarioAtencion> horarios) {
    final grouped = <String, List<HorarioAtencion>>{};
    for (final horario in horarios) {
      grouped.putIfAbsent(horario.diaSemana, () => []).add(horario);
    }

    return grouped.entries.map((entry) {
      return _HorarioDayGroup(
        dayLabel: entry.value.first.diaLabel,
        horarios: entry.value,
      );
    }).toList();
  }

  Future<void> _openHorarioForm(
    BuildContext context, [
    HorarioAtencion? horario,
  ]) async {
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
          value: context.read<HorariosProvider>(),
          child: HorarioFormSheet(horario: horario),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HorarioAtencion horario,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Desactivar horario'),
          content: Text('Se desactivara el horario de ${horario.diaLabel}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirm != true) {
      return;
    }

    final message = await context.read<HorariosProvider>().delete(horario.id);

    if (!context.mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HorarioDayGroup {
  const _HorarioDayGroup({
    required this.dayLabel,
    required this.horarios,
  });

  final String dayLabel;
  final List<HorarioAtencion> horarios;
}
