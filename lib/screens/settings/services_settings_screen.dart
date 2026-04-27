import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/servicio.dart';
import 'package:odontologia_app/providers/servicios_provider.dart';
import 'package:odontologia_app/services/servicios_service.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:odontologia_app/widgets/app_bottom_navigation.dart';
import 'package:provider/provider.dart';

class ServicesSettingsScreen extends StatefulWidget {
  const ServicesSettingsScreen({super.key});

  @override
  State<ServicesSettingsScreen> createState() => _ServicesSettingsScreenState();
}

class _ServicesSettingsScreenState extends State<ServicesSettingsScreen> {
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
        context.read<ServiciosProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final servicios = context.watch<ServiciosProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral,
      bottomNavigationBar: const AppBottomNavigation(currentTab: AppTab.settings),
      floatingActionButton: FloatingActionButton(
        onPressed: servicios.isSaving ? null : () => _openServicioForm(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: _SectionHeader(
                  title: 'Servicios',
                  subtitle: 'Tratamientos disponibles',
                  onBack: () => context.pop(),
                  onRefresh: servicios.isLoading
                      ? null
                      : () => context.read<ServiciosProvider>().load(),
                ),
              ),
            ),
            if (servicios.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (servicios.errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _SettingsMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'No se pudieron cargar los servicios',
                  message: servicios.errorMessage!,
                  actionLabel: 'Reintentar',
                  onAction: () => context.read<ServiciosProvider>().load(),
                ),
              )
            else if (servicios.servicios.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _SettingsMessage(
                  icon: Icons.medical_services_rounded,
                  title: 'Sin servicios registrados',
                  message: 'Agrega los tratamientos que ofrece la clinica.',
                  actionLabel: 'Agregar servicio',
                  onAction: () => _openServicioForm(context),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                sliver: SliverList.separated(
                  itemCount: servicios.servicios.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final servicio = servicios.servicios[index];
                    return _ServicioCard(
                      servicio: servicio,
                      onEdit: () => _openServicioForm(context, servicio),
                      onDelete: () => _confirmDelete(context, servicio),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openServicioForm(
    BuildContext context, [
    Servicio? servicio,
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
          value: context.read<ServiciosProvider>(),
          child: _ServicioFormSheet(servicio: servicio),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Servicio servicio) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Desactivar servicio'),
          content: Text('Se desactivara el servicio ${servicio.nombre}.'),
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

    final message = await context.read<ServiciosProvider>().delete(servicio.id);

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

class _ServicioCard extends StatelessWidget {
  const _ServicioCard({
    required this.servicio,
    required this.onEdit,
    required this.onDelete,
  });

  final Servicio servicio;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final description = servicio.descripcion?.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  servicio.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.inverted,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description == null || description.isEmpty
                      ? 'Sin descripcion'
                      : description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusPill(isActive: servicio.activo),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 11,
            ),
      ),
    );
  }
}

class _ServicioFormSheet extends StatefulWidget {
  const _ServicioFormSheet({
    this.servicio,
  });

  final Servicio? servicio;

  @override
  State<_ServicioFormSheet> createState() => _ServicioFormSheetState();
}

class _ServicioFormSheetState extends State<_ServicioFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final servicio = widget.servicio;
    _nombreController.text = servicio?.nombre ?? '';
    _descripcionController.text = servicio?.descripcion ?? '';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiciosProvider>();
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
                widget.servicio == null ? 'Nuevo servicio' : 'Editar servicio',
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  color: AppColors.inverted,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nombreController,
                enabled: !provider.isSaving,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Limpieza dental',
                  prefixIcon: Icon(Icons.medical_services_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre del servicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descripcionController,
                enabled: !provider.isSaving,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripcion',
                  hintText: 'Detalle breve del tratamiento',
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
                      : const Text('Guardar servicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = ServicioRequest(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
    );

    final message = await context.read<ServiciosProvider>().save(
          id: widget.servicio?.id,
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
