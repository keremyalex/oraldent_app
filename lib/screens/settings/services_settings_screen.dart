import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/servicio.dart';
import 'package:odontologia_app/providers/servicios_provider.dart';
import 'package:odontologia_app/screens/settings/widgets/servicio_card.dart';
import 'package:odontologia_app/screens/settings/widgets/servicio_form_sheet.dart';
import 'package:odontologia_app/screens/settings/widgets/settings_header.dart';
import 'package:odontologia_app/screens/settings/widgets/settings_message.dart';
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
      bottomNavigationBar: const AppBottomNavigation(
        currentTab: AppTab.settings,
      ),
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
                child: SettingsHeader(
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
                child: SettingsMessage(
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
                child: SettingsMessage(
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
                    return ServicioCard(
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
          child: ServicioFormSheet(servicio: servicio),
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
