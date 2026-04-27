import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/providers/pacientes_provider.dart';
import 'package:odontologia_app/services/pacientes_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:odontologia_app/widgets/app_back_guard.dart';
import 'package:odontologia_app/widgets/app_bottom_navigation.dart';
import 'package:provider/provider.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final _searchController = TextEditingController();
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
        context.read<PacientesProvider>().load();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PacientesProvider>();
    final auth = context.watch<AuthProvider>();
    final textTheme = Theme.of(context).textTheme;
    final pacientes = provider.filteredPacientes;

    return DashboardBackGuard(
      child: Scaffold(
        backgroundColor: AppColors.neutral,
        bottomNavigationBar: const AppBottomNavigation(
          currentTab: AppTab.patients,
        ),
        body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                child: _PacientesHeader(
                  userRole: auth.usuario?.rol ?? 'Staff',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: context.read<PacientesProvider>().updateQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, CI, celular o correo',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: provider.query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<PacientesProvider>()
                                  .updateQuery('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${pacientes.length} pacientes',
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 23,
                          color: AppColors.inverted,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => context.read<PacientesProvider>().load(),
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
            if (provider.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _PacientesMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'No se pudieron cargar los pacientes',
                  message: provider.errorMessage!,
                  actionLabel: 'Reintentar',
                  onAction: () => context.read<PacientesProvider>().load(),
                ),
              )
            else if (pacientes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _PacientesMessage(
                  icon: Icons.group_off_rounded,
                  title: provider.query.isEmpty
                      ? 'No hay pacientes registrados'
                      : 'Sin resultados',
                  message: provider.query.isEmpty
                      ? 'Cuando registres pacientes apareceran aqui.'
                      : 'Prueba con otro nombre, celular, CI o correo.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverList.separated(
                  itemCount: pacientes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _PacienteCard(
                      paciente: pacientes[index],
                      onTap: () => _openPacienteForm(
                        context,
                        pacientes[index],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openPacienteForm(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.person_add_alt_1_rounded),
        ),
      ),
    );
  }

  Future<void> _openPacienteForm(
    BuildContext context, [
    Paciente? paciente,
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
          value: context.read<PacientesProvider>(),
          child: _PacienteFormSheet(paciente: paciente),
        );
      },
    );
  }
}

class _PacientesHeader extends StatelessWidget {
  const _PacientesHeader({
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
                'Pacientes',
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 32,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gestion de historiales • $userRole',
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

class _PacienteCard extends StatelessWidget {
  const _PacienteCard({
    required this.paciente,
    required this.onTap,
  });

  final Paciente paciente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PatientAvatar(paciente: paciente),
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
                        paciente.nombreCompleto,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.inverted,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const _StatusChip(),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      icon: Icons.phone_rounded,
                      text: paciente.celular,
                    ),
                    if (paciente.documentoIdentidad != null &&
                        paciente.documentoIdentidad!.isNotEmpty)
                      _InfoPill(
                        icon: Icons.badge_outlined,
                        text: paciente.documentoIdentidad!,
                      ),
                  ],
                ),
                if (paciente.correo != null && paciente.correo!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoPill(
                    icon: Icons.mail_outline_rounded,
                    text: paciente.correo!,
                  ),
                ],
                if (paciente.direccion != null &&
                    paciente.direccion!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoPill(
                    icon: Icons.location_on_outlined,
                    text: paciente.direccion!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.edit_rounded,
            color: AppColors.secondary.withValues(alpha: 0.7),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _PatientAvatar extends StatelessWidget {
  const _PatientAvatar({
    required this.paciente,
  });

  final Paciente paciente;

  @override
  Widget build(BuildContext context) {
    final photo = paciente.fotoUrl;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: photo == null || photo.isEmpty
          ? Center(
              child: Text(
                paciente.initials,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            )
          : Image.network(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    paciente.initials,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                );
              },
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'Activo',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF00786B),
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

class _PacienteFormSheet extends StatefulWidget {
  const _PacienteFormSheet({
    this.paciente,
  });

  final Paciente? paciente;

  @override
  State<_PacienteFormSheet> createState() => _PacienteFormSheetState();
}

class _PacienteFormSheetState extends State<_PacienteFormSheet> {
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

class _PacientesMessage extends StatelessWidget {
  const _PacientesMessage({
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
