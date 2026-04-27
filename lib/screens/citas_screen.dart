import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/cita.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/providers/citas_provider.dart';
import 'package:odontologia_app/providers/pacientes_provider.dart';
import 'package:odontologia_app/providers/servicios_provider.dart';
import 'package:odontologia_app/services/citas_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:odontologia_app/widgets/app_back_guard.dart';
import 'package:odontologia_app/widgets/app_bottom_navigation.dart';
import 'package:provider/provider.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
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
        context.read<CitasProvider>().load();
        context.read<PacientesProvider>().load();
        context.read<ServiciosProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final citasProvider = context.watch<CitasProvider>();
    final auth = context.watch<AuthProvider>();
    final textTheme = Theme.of(context).textTheme;

    return DashboardBackGuard(
      child: Scaffold(
        backgroundColor: AppColors.neutral,
        bottomNavigationBar: const AppBottomNavigation(
          currentTab: AppTab.appointments,
        ),
        body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                child: _CitasHeader(
                  userRole: auth.usuario?.rol ?? 'Staff',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: EasyDateTimeLine(
                  initialDate: citasProvider.selectedDate,
                  locale: 'es_ES',
                  activeColor: AppColors.primary,
                  onDateChange: (date) {
                    context.read<CitasProvider>().load(date: date);
                  },
                  headerProps: EasyHeaderProps(
                    showMonthPicker: true,
                    monthPickerType: MonthPickerType.switcher,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    selectedDateStyle: textTheme.labelLarge?.copyWith(
                      color: AppColors.inverted,
                    ),
                    monthStyle: textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  timeLineProps: const EasyTimeLineProps(
                    hPadding: 24,
                    separatorPadding: 10,
                  ),
                  dayProps: EasyDayProps(
                    width: 64,
                    height: 82,
                    dayStructure: DayStructure.dayStrDayNum,
                    todayHighlightStyle: TodayHighlightStyle.withBackground,
                    todayHighlightColor:
                        AppColors.tertiary.withValues(alpha: 0.16),
                    activeDayStyle: DayStyle(
                      borderRadius: 16,
                      dayNumStyle: textTheme.displayLarge?.copyWith(
                        fontSize: 22,
                        color: Colors.white,
                        height: 1,
                      ),
                      dayStrStyle: textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    inactiveDayStyle: DayStyle(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      dayNumStyle: textTheme.displayLarge?.copyWith(
                        fontSize: 21,
                        color: AppColors.inverted,
                        height: 1,
                      ),
                      dayStrStyle: textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    todayStyle: DayStyle(
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.tertiary.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dateTitle(citasProvider.selectedDate),
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 23,
                        color: AppColors.inverted,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => context.read<CitasProvider>().load(),
                      icon: const Icon(Icons.refresh_rounded),
                      color: AppColors.primary,
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (citasProvider.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (citasProvider.errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _CitasMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'No se pudieron cargar las citas',
                  message: citasProvider.errorMessage!,
                  actionLabel: 'Reintentar',
                  onAction: () => context.read<CitasProvider>().load(),
                ),
              )
            else if (citasProvider.citas.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _CitasMessage(
                  icon: Icons.event_busy_rounded,
                  title: 'No hay citas para esta fecha',
                  message: 'Selecciona otro dia o registra una nueva cita.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverList.separated(
                  itemCount: citasProvider.citas.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cita = citasProvider.citas[index];
                    return _CitaTimelineCard(
                      cita: cita,
                      onTap: () => _openCitaForm(context, cita),
                    );
                  },
                ),
              ),
          ],
        ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openCitaForm(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  String _dateTitle(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day de $month';
  }

  Future<void> _openCitaForm(BuildContext context, [Cita? cita]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<CitasProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<PacientesProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<ServiciosProvider>(),
            ),
          ],
          child: _CitaFormSheet(cita: cita),
        );
      },
    );
  }
}

class _CitasHeader extends StatelessWidget {
  const _CitasHeader({
    required this.userRole,
  });

  final String userRole;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Citas',
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 32,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Agenda odontologica • $userRole',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => context.go('/dashboard'),
          icon: const Icon(Icons.home_rounded),
          color: AppColors.primary,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            fixedSize: const Size(48, 48),
          ),
        ),
      ],
    );
  }
}

class _CitaTimelineCard extends StatelessWidget {
  const _CitaTimelineCard({
    required this.cita,
    required this.onTap,
  });

  final Cita cita;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _statusColor(cita.estado);
    final duration = cita.fechaHoraFin.difference(cita.fechaHoraInicio);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
          width: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                cita.hora,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.inverted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'hrs',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
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
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                cita.paciente.nombreCompleto,
                                style: textTheme.labelLarge?.copyWith(
                                  color: AppColors.inverted,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _StatusChip(
                              label: _statusLabel(cita.estado),
                              color: color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          cita.motivo,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (cita.servicio != null) ...[
                          const SizedBox(height: 8),
                          _InfoPill(
                            icon: Icons.medical_services_outlined,
                            text: cita.servicio!.nombre,
                          ),
                        ],
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _InfoPill(
                              icon: Icons.schedule_rounded,
                              text: '${duration.inMinutes} min',
                            ),
                            _InfoPill(
                              icon: Icons.phone_rounded,
                              text: cita.paciente.celular,
                            ),
                          ],
                        ),
                        if (cita.notas != null && cita.notas!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            cita.notas!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'CONFIRMADA' => AppColors.tertiary,
      'PENDIENTE' => AppColors.primary,
      'REPROGRAMADA' => const Color(0xFF505F76),
      'ATENDIDA' => const Color(0xFF00786B),
      'CANCELADA' || 'NO_ASISTIO' => const Color(0xFFBA1A1A),
      _ => AppColors.primary,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'CONFIRMADA' => 'Confirmada',
      'PENDIENTE' => 'Pendiente',
      'REPROGRAMADA' => 'Reprogramada',
      'ATENDIDA' => 'Atendida',
      'CANCELADA' => 'Cancelada',
      'NO_ASISTIO' => 'No asistio',
      _ => status,
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _CitaFormSheet extends StatefulWidget {
  const _CitaFormSheet({
    this.cita,
  });

  final Cita? cita;

  @override
  State<_CitaFormSheet> createState() => _CitaFormSheetState();
}

class _CitaFormSheetState extends State<_CitaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  final _notasController = TextEditingController();

  int? _pacienteId;
  int? _servicioId;
  late DateTime _fecha;
  String? _selectedTime;
  List<String> _availableTimes = [];
  bool _loadingAvailability = false;
  String? _availabilityError;
  bool _initialized = false;

  bool get _isEditing => widget.cita != null;

  @override
  void initState() {
    super.initState();
    final cita = widget.cita;
    _fecha = cita == null
        ? DateTime.now()
        : DateTime(
            cita.fechaHoraInicio.year,
            cita.fechaHoraInicio.month,
            cita.fechaHoraInicio.day,
          );
    _selectedTime = cita == null ? null : _formatTime(cita.fechaHoraInicio);
    _pacienteId = cita?.paciente.id;
    _servicioId = cita?.servicio?.id;
    _motivoController.text = cita?.motivo ?? '';
    _notasController.text = cita?.notas ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadAvailability();
      }
    });
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citasProvider = context.watch<CitasProvider>();
    final pacientesProvider = context.watch<PacientesProvider>();
    final serviciosProvider = context.watch<ServiciosProvider>();
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final pacienteOptions = [...pacientesProvider.pacientes];
    final currentPaciente = widget.cita?.paciente;
    if (currentPaciente != null &&
        !pacienteOptions.any((item) => item.id == currentPaciente.id)) {
      pacienteOptions.add(currentPaciente);
    }
    final servicioOptions = [...serviciosProvider.servicios];
    final currentServicio = widget.cita?.servicio;
    if (currentServicio != null &&
        !servicioOptions.any((item) => item.id == currentServicio.id)) {
      servicioOptions.add(currentServicio);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 22, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Reprogramar cita' : 'Registrar cita',
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  color: AppColors.inverted,
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 8),
                // Text(
                //   'La API actual permite editar la fecha y hora. Paciente, servicio y motivo quedan como referencia.',
                //   style: textTheme.labelLarge?.copyWith(
                //     color: AppColors.secondary,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
              const SizedBox(height: 18),
              DropdownButtonFormField<int>(
                initialValue: _pacienteId,
                decoration: const InputDecoration(
                  labelText: 'Paciente',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                items: pacienteOptions.map((paciente) {
                  return DropdownMenuItem(
                    value: paciente.id,
                    child: Text(
                      paciente.nombreCompleto,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: _isEditing || citasProvider.isSaving
                    ? null
                    : (value) => setState(() => _pacienteId = value),
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona un paciente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                initialValue: _servicioId,
                decoration: const InputDecoration(
                  labelText: 'Servicio',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                items: servicioOptions.map((servicio) {
                  return DropdownMenuItem(
                    value: servicio.id,
                    child: Text(
                      servicio.nombre,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: _isEditing || citasProvider.isSaving
                    ? null
                    : (value) => setState(() => _servicioId = value),
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona un servicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _DateButton(
                value: _fecha,
                enabled: !citasProvider.isSaving,
                onPick: () => _pickDate(context),
              ),
              const SizedBox(height: 14),
              _AvailabilityPicker(
                selectedTime: _selectedTime,
                availableTimes: _availableTimes,
                isLoading: _loadingAvailability,
                errorMessage: _availabilityError,
                onSelected: citasProvider.isSaving
                    ? null
                    : (value) => setState(() => _selectedTime = value),
                onRetry: _loadAvailability,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _motivoController,
                enabled: !_isEditing && !citasProvider.isSaving,
                minLines: 2,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el motivo';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notasController,
                enabled: !_isEditing && !citasProvider.isSaving,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: citasProvider.isSaving ? null : () => _save(context),
                  child: citasProvider.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditing ? 'Guardar nueva hora' : 'Registrar cita'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _fecha = DateTime(picked.year, picked.month, picked.day);
      _selectedTime = null;
    });
    await _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _loadingAvailability = true;
      _availabilityError = null;
    });

    try {
      final times = await context.read<CitasProvider>().disponibilidad(_fecha);
      if (!mounted) {
        return;
      }
      final currentTime = widget.cita == null ? null : _formatTime(widget.cita!.fechaHoraInicio);
      setState(() {
        _availableTimes = [
          ...times,
          if (_isEditing && currentTime != null && _isSameDate(_fecha, widget.cita!.fechaHoraInicio) && !times.contains(currentTime))
            currentTime,
        ]..sort();
        if (_selectedTime != null && !_availableTimes.contains(_selectedTime)) {
          _selectedTime = null;
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _availabilityError = apiErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() => _loadingAvailability = false);
      }
    }
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una hora disponible.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final dateTime = _combineDateAndTime(_fecha, _selectedTime!);
    final provider = context.read<CitasProvider>();
    final String? message;

    if (_isEditing) {
      message = await provider.reprogramar(
        cita: widget.cita!,
        nuevaFechaHoraInicio: dateTime,
      );
    } else {
      message = await provider.crear(
        CitaRequest(
          pacienteId: _pacienteId!,
          servicioId: _servicioId!,
          fechaHoraInicio: dateTime,
          motivo: _motivoController.text.trim(),
          notas: _emptyToNull(_notasController.text),
        ),
      );
    }

    if (!context.mounted) {
      return;
    }

    if (message == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Cita reprogramada correctamente.'
              : 'Cita registrada correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  DateTime _combineDateAndTime(DateTime date, String time) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.value,
    required this.enabled,
    required this.onPick,
  });

  final DateTime value;
  final bool enabled;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onPick : null,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        foregroundColor: AppColors.inverted,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(value),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _AvailabilityPicker extends StatelessWidget {
  const _AvailabilityPicker({
    required this.selectedTime,
    required this.availableTimes,
    required this.isLoading,
    required this.errorMessage,
    required this.onSelected,
    required this.onRetry,
  });

  final String? selectedTime;
  final List<String> availableTimes;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String>? onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(errorMessage!),
      );
    }

    if (availableTimes.isEmpty) {
      return Text(
        'No hay horarios disponibles para esta fecha.',
        style: textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTimes.map((time) {
        final selected = selectedTime == time;
        return ChoiceChip(
          label: Text(_shortTime(time)),
          selected: selected,
          onSelected: onSelected == null ? null : (_) => onSelected!(time),
          selectedColor: AppColors.primary.withValues(alpha: 0.16),
          labelStyle: textTheme.labelLarge?.copyWith(
            color: selected ? AppColors.primary : AppColors.inverted,
          ),
        );
      }).toList(),
    );
  }

  String _shortTime(String time) {
    final parts = time.split(':');
    return '${parts[0]}:${parts[1]}';
  }
}

class _CitasMessage extends StatelessWidget {
  const _CitasMessage({
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

const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];
