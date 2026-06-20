import 'package:flutter/material.dart';
import 'package:odontologia_app/models/usuario_auth.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/services/auth_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ProfileFormSheet extends StatefulWidget {
  const ProfileFormSheet({required this.usuario, super.key});

  final UsuarioAuth usuario;

  @override
  State<ProfileFormSheet> createState() => _ProfileFormSheetState();
}

class _ProfileFormSheetState extends State<ProfileFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _correoController = TextEditingController();
  final _celularController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final usuario = widget.usuario;
    _nombreController.text = usuario.nombre;
    _apellidoPaternoController.text = usuario.apellidoPaterno;
    _apellidoMaternoController.text = usuario.apellidoMaterno ?? '';
    _correoController.text = usuario.correo ?? '';
    _celularController.text = usuario.celular;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _correoController.dispose();
    _celularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Editar datos',
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 24,
                        color: AppColors.inverted,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: auth.isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar sin guardar',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ProfileTextField(
                controller: _nombreController,
                label: 'Nombre',
                icon: Icons.person_outline_rounded,
                enabled: !auth.isLoading,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              _ProfileTextField(
                controller: _apellidoPaternoController,
                label: 'Apellido paterno',
                icon: Icons.person_outline_rounded,
                enabled: !auth.isLoading,
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              _ProfileTextField(
                controller: _apellidoMaternoController,
                label: 'Apellido materno',
                icon: Icons.person_outline_rounded,
                enabled: !auth.isLoading,
              ),
              const SizedBox(height: 14),
              _ProfileTextField(
                controller: _correoController,
                label: 'Correo',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                enabled: !auth.isLoading,
                validator: _emailValidator,
              ),
              const SizedBox(height: 14),
              _ProfileTextField(
                controller: _celularController,
                label: 'Celular',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                enabled: !auth.isLoading,
                validator: _phoneValidator,
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: auth.isLoading ? null : () => _save(context),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar cambios'),
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
      return 'Campo obligatorio';
    }
    if (!text.contains('@')) {
      return 'Correo invalido';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Campo obligatorio';
    }
    if (!RegExp(r'^[0-9]{7,15}$').hasMatch(text)) {
      return 'Ingresa entre 7 y 15 digitos';
    }
    return null;
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = PerfilUsuarioRequest(
      nombre: _nombreController.text.trim(),
      apellidoPaterno: _apellidoPaternoController.text.trim(),
      apellidoMaterno: _emptyToNull(_apellidoMaternoController.text),
      correo: _correoController.text.trim(),
      celular: _celularController.text.trim(),
    );

    final message = await context.read<AuthProvider>().updateProfile(request);

    if (!context.mounted) {
      return;
    }

    if (message == null) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
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
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
