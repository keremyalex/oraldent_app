import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/horario_atencion.dart';
import 'package:odontologia_app/providers/horarios_provider.dart';
import 'package:odontologia_app/services/horarios_service.dart';
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
      bottomNavigationBar: const AppBottomNavigation(currentTab: AppTab.settings),
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
                child: _SectionHeader(
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
                child: _SettingsMessage(
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
                child: _SettingsMessage(
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
                    return _HorarioDaySection(
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
          child: _HorarioFormSheet(horario: horario),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onRefresh,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.primary,
          style: IconButton.styleFrom(backgroundColor: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 28,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.primary,
          style: IconButton.styleFrom(backgroundColor: Colors.white),
        ),
      ],
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

class _HorarioDaySection extends StatelessWidget {
  const _HorarioDaySection({
    required this.dayLabel,
    required this.horarios,
    required this.onEdit,
    required this.onDelete,
  });

  final String dayLabel;
  final List<HorarioAtencion> horarios;
  final ValueChanged<HorarioAtencion> onEdit;
  final ValueChanged<HorarioAtencion> onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${horarios.length} ${horarios.length == 1 ? 'bloque' : 'bloques'} de atencion',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < horarios.length; index++) ...[
            if (index > 0) const SizedBox(height: 10),
            _HorarioBlockTile(
              horario: horarios[index],
              onEdit: () => onEdit(horarios[index]),
              onDelete: () => onDelete(horarios[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _HorarioBlockTile extends StatelessWidget {
  const _HorarioBlockTile({
    required this.horario,
    required this.onEdit,
    required this.onDelete,
  });

  final HorarioAtencion horario;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  horario.rango,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.inverted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    '${horario.duracionCitaMinutos} min por cita',
                    if (horario.observacion != null &&
                        horario.observacion!.isNotEmpty)
                      horario.observacion!,
                  ].join(' - '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              }
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Desactivar')),
            ],
          ),
        ],
      ),
    );
  }
}

class _HorarioFormSheet extends StatefulWidget {
  const _HorarioFormSheet({
    this.horario,
  });

  final HorarioAtencion? horario;

  @override
  State<_HorarioFormSheet> createState() => _HorarioFormSheetState();
}

class _HorarioFormSheetState extends State<_HorarioFormSheet> {
  final _observacionController = TextEditingController();
  late String _diaSemana;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;
  late int _duracion;

  @override
  void initState() {
    super.initState();
    final horario = widget.horario;
    _diaSemana = _normalizeDay(horario?.diaSemana ?? 'LUNES');
    _horaInicio = horario?.horaInicio ?? const TimeOfDay(hour: 8, minute: 30);
    _horaFin = horario?.horaFin ?? const TimeOfDay(hour: 18, minute: 30);
    _duracion = horario?.duracionCitaMinutos ?? 30;
    _observacionController.text = horario?.observacion ?? '';
  }

  String _normalizeDay(String day) {
    return switch (day) {
      'MONDAY' => 'LUNES',
      'TUESDAY' => 'MARTES',
      'WEDNESDAY' => 'MIERCOLES',
      'THURSDAY' => 'JUEVES',
      'FRIDAY' => 'VIERNES',
      'SATURDAY' => 'SABADO',
      'SUNDAY' => 'DOMINGO',
      _ => day,
    };
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HorariosProvider>();
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 22, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.horario == null ? 'Nuevo horario' : 'Editar horario',
              style: textTheme.displayLarge?.copyWith(
                fontSize: 24,
                color: AppColors.inverted,
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _diaSemana,
              decoration: const InputDecoration(
                labelText: 'Dia de atencion',
                prefixIcon: Icon(Icons.calendar_today_rounded),
              ),
              items: _weekDays.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: provider.isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _diaSemana = value);
                      }
                    },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TimeButton(
                    label: 'Inicio',
                    value: HorarioAtencion.formatTime(_horaInicio),
                    onTap: provider.isSaving
                        ? null
                        : () => _pickTime(
                              context: context,
                              current: _horaInicio,
                              onPicked: (value) {
                                setState(() => _horaInicio = value);
                              },
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeButton(
                    label: 'Fin',
                    value: HorarioAtencion.formatTime(_horaFin),
                    onTap: provider.isSaving
                        ? null
                        : () => _pickTime(
                              context: context,
                              current: _horaFin,
                              onPicked: (value) {
                                setState(() => _horaFin = value);
                              },
                            ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: _duracion,
              decoration: const InputDecoration(
                labelText: 'Duracion de cita',
                prefixIcon: Icon(Icons.timelapse_rounded),
              ),
              items: const [10, 15, 20, 30, 45, 60, 90, 120].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text('$minutes minutos'),
                );
              }).toList(),
              onChanged: provider.isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _duracion = value);
                      }
                    },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _observacionController,
              enabled: !provider.isSaving,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observacion',
                hintText: 'Turnos habilitados',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: provider.isSaving ? null : () => _save(context),
                child: provider.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar horario'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime({
    required BuildContext context,
    required TimeOfDay current,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  Future<void> _save(BuildContext context) async {
    final request = HorarioRequest(
      diaSemana: _diaSemana,
      horaInicio: _horaInicio,
      horaFin: _horaFin,
      duracionCitaMinutos: _duracion,
      observacion: _observacionController.text.trim().isEmpty
          ? null
          : _observacionController.text.trim(),
    );

    final message = await context.read<HorariosProvider>().save(
          id: widget.horario?.id,
          request: request,
        );

    if (!context.mounted) {
      return;
    }

    if (message == null) {
      Navigator.of(context).pop();
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

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: AppColors.inverted,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.inverted,
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMessage extends StatelessWidget {
  const _SettingsMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 44, color: AppColors.secondary),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.displayLarge?.copyWith(
              fontSize: 22,
              color: AppColors.inverted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: AppColors.secondary),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

const _weekDays = {
  'LUNES': 'Lunes',
  'MARTES': 'Martes',
  'MIERCOLES': 'Miercoles',
  'JUEVES': 'Jueves',
  'VIERNES': 'Viernes',
  'SABADO': 'Sabado',
  'DOMINGO': 'Domingo',
};
