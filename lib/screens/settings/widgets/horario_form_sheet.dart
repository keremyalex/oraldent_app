import 'package:flutter/material.dart';
import 'package:odontologia_app/models/horario_atencion.dart';
import 'package:odontologia_app/providers/horarios_provider.dart';
import 'package:odontologia_app/services/horarios_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class HorarioFormSheet extends StatefulWidget {
  const HorarioFormSheet({this.horario, super.key});

  final HorarioAtencion? horario;

  @override
  State<HorarioFormSheet> createState() => _HorarioFormSheetState();
}

class _HorarioFormSheetState extends State<HorarioFormSheet> {
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.horario == null ? 'Nuevo horario' : 'Editar horario',
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: 24,
                      color: AppColors.inverted,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: provider.isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Cerrar sin guardar',
                ),
              ],
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
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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

const _weekDays = {
  'LUNES': 'Lunes',
  'MARTES': 'Martes',
  'MIERCOLES': 'Miercoles',
  'JUEVES': 'Jueves',
  'VIERNES': 'Viernes',
  'SABADO': 'Sabado',
  'DOMINGO': 'Domingo',
};
