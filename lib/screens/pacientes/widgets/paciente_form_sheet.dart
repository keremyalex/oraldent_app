import 'package:flutter/material.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/providers/pacientes_provider.dart';
import 'package:odontologia_app/services/pacientes_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class PacienteFormSheet extends StatefulWidget {
  const PacienteFormSheet({
    this.paciente,
    super.key,
  });

  final Paciente? paciente;

  @override
  State<PacienteFormSheet> createState() => _PacienteFormSheetState();
}

class _PacienteFormSheetState extends State<PacienteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _celularController = TextEditingController();
  final _documentoController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _fotoController = TextEditingController();
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    final paciente = widget.paciente;
    if (paciente != null) {
      _nombreController.text = paciente.nombre;
      _apellidoPaternoController.text = paciente.apellidoPaterno;
      _apellidoMaternoController.text = paciente.apellidoMaterno ?? '';
      _celularController.text = paciente.celular;
      _documentoController.text = paciente.documentoIdentidad ?? '';
      _correoController.text = paciente.correo ?? '';
      _direccionController.text = paciente.direccion ?? '';
      _fotoController.text = paciente.fotoUrl ?? '';
      _fechaNacimiento = paciente.fechaNacimiento;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _celularController.dispose();
    _documentoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PacientesProvider>();
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

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
                widget.paciente == null
                    ? 'Registrar paciente'
                    : 'Editar paciente',
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  color: AppColors.inverted,
                ),
              ),
              const SizedBox(height: 18),
              _PatientTextField(
                controller: _nombreController,
                label: 'Nombre',
                icon: Icons.person_outline_rounded,
                enabled: !provider.isSaving,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              _PatientTextField(
                controller: _apellidoPaternoController,
                label: 'Apellido paterno',
                icon: Icons.person_outline_rounded,
                enabled: !provider.isSaving,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              _PatientTextField(
                controller: _apellidoMaternoController,
                label: 'Apellido materno',
                icon: Icons.person_outline_rounded,
                enabled: !provider.isSaving,
              ),
              const SizedBox(height: 14),
              _PatientTextField(
                controller: _celularController,
                label: 'Celular',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                enabled: !provider.isSaving,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              _PatientTextField(
                controller: _documentoController,
                label: 'Documento de identidad',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                enabled: !provider.isSaving,
              ),
              const SizedBox(height: 14),
              _PatientTextField(
                controller: _correoController,
                label: 'Correo',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                enabled: !provider.isSaving,
                validator: _emailValidator,
              ),
              const SizedBox(height: 14),
              _DateFieldButton(
                value: _fechaNacimiento,
                enabled: !provider.isSaving,
                onPick: () => _pickBirthDate(context),
                onClear: _fechaNacimiento == null
                    ? null
                    : () => setState(() => _fechaNacimiento = null),
              ),
              const SizedBox(height: 14),
              _PatientTextField(
                controller: _direccionController,
                label: 'Direccion',
                icon: Icons.location_on_outlined,
                enabled: !provider.isSaving,
              ),
              const SizedBox(height: 14),
              _PatientTextField(
                controller: _fotoController,
                label: 'URL de foto',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
                enabled: !provider.isSaving,
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
                      : const Text('Guardar paciente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    if (!text.contains('@')) {
      return 'Correo invalido';
    }
    return null;
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = PacienteRequest(
      nombre: _nombreController.text.trim(),
      apellidoPaterno: _apellidoPaternoController.text.trim(),
      apellidoMaterno: _emptyToNull(_apellidoMaternoController.text),
      celular: _celularController.text.trim(),
      documentoIdentidad: _emptyToNull(_documentoController.text),
      correo: _emptyToNull(_correoController.text),
      fechaNacimiento: _fechaNacimiento,
      direccion: _emptyToNull(_direccionController.text),
      fotoUrl: _emptyToNull(_fotoController.text),
    );

    final message = await context.read<PacientesProvider>().save(
          id: widget.paciente?.id,
          request: request,
        );

    if (!context.mounted) {
      return;
    }

    if (message == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.paciente == null
                ? 'Paciente registrado correctamente.'
                : 'Paciente actualizado correctamente.',
          ),
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

  String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}

class _PatientTextField extends StatelessWidget {
  const _PatientTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.enabled = true,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class _DateFieldButton extends StatelessWidget {
  const _DateFieldButton({
    required this.value,
    required this.enabled,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? value;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback? onClear;

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
          const Icon(Icons.cake_outlined, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fecha de nacimiento',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value == null ? 'Sin fecha' : _formatDate(value!),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: enabled ? onClear : null,
              icon: const Icon(Icons.close_rounded),
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
