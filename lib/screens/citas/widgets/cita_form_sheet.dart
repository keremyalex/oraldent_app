import 'package:flutter/material.dart';
import 'package:odontologia_app/core/api_client.dart';
import 'package:odontologia_app/models/cita.dart';
import 'package:odontologia_app/providers/citas_provider.dart';
import 'package:odontologia_app/providers/pacientes_provider.dart';
import 'package:odontologia_app/providers/servicios_provider.dart';
import 'package:odontologia_app/services/citas_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class CitaFormSheet extends StatefulWidget {
  const CitaFormSheet({this.cita, super.key});

  final Cita? cita;

  @override
  State<CitaFormSheet> createState() => _CitaFormSheetState();
}

class _CitaFormSheetState extends State<CitaFormSheet> {
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Reprogramar cita' : 'Registrar cita',
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 24,
                        color: AppColors.inverted,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: citasProvider.isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar sin guardar',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<int>(
                initialValue: _pacienteId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Paciente',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                items: pacienteOptions.map((paciente) {
                  return DropdownMenuItem(
                    value: paciente.id,
                    child: Text(
                      paciente.nombreCompleto,
                      maxLines: 1,
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
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Servicio',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                items: servicioOptions.map((servicio) {
                  return DropdownMenuItem(
                    value: servicio.id,
                    child: Text(
                      servicio.nombre,
                      maxLines: 1,
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
                  onPressed: citasProvider.isSaving
                      ? null
                      : () => _save(context),
                  child: citasProvider.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Guardar nueva hora' : 'Registrar cita',
                        ),
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
      final currentTime = widget.cita == null
          ? null
          : _formatTime(widget.cita!.fechaHoraInicio);
      setState(() {
        _availableTimes = [
          ...times,
          if (_isEditing &&
              currentTime != null &&
              _isSameDate(_fecha, widget.cita!.fechaHoraInicio) &&
              !times.contains(currentTime))
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
          content: Text(
            _isEditing
                ? 'Cita reprogramada correctamente.'
                : 'Cita registrada correctamente.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
