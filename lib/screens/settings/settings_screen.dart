import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/usuario_auth.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/screens/settings/widgets/profile_card.dart';
import 'package:odontologia_app/screens/settings/widgets/profile_form_sheet.dart';
import 'package:odontologia_app/screens/settings/widgets/settings_header.dart';
import 'package:odontologia_app/screens/settings/widgets/settings_option_card.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:odontologia_app/widgets/app_back_guard.dart';
import 'package:odontologia_app/widgets/app_bottom_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return DashboardBackGuard(
      child: Scaffold(
        backgroundColor: AppColors.neutral,
        bottomNavigationBar: const AppBottomNavigation(
          currentTab: AppTab.settings,
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: SettingsHeader(
                    title: 'Ajustes',
                    subtitle: 'Perfil y configuracion',
                    onHome: () => context.go('/citas'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: ProfileCard(
                    usuario: auth.usuario,
                    isUploadingPhoto: auth.isLoading,
                    onEditProfile: () => _openProfileForm(
                      context,
                      auth.usuario,
                    ),
                    onChangePhoto: () => _pickProfilePhoto(context),
                    onLogout: () async {
                      await context.read<AuthProvider>().logout();
                      if (!context.mounted) {
                        return;
                      }
                      context.go('/login');
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: Text(
                    'Configuracion de la clinica',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 23,
                          color: AppColors.inverted,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverList.list(
                  children: [
                    SettingsOptionCard(
                      icon: Icons.schedule_rounded,
                      title: 'Horario de atencion',
                      subtitle: 'Dias, bloques y duracion de cada cita',
                      onTap: () => context.push('/ajustes/horarios'),
                    ),
                    const SizedBox(height: 12),
                    SettingsOptionCard(
                      icon: Icons.medical_services_rounded,
                      title: 'Servicios',
                      subtitle: 'Tratamientos disponibles para las citas',
                      onTap: () => context.push('/ajustes/servicios'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfilePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );

    if (image == null || !context.mounted) {
      return;
    }

    final message = await context.read<AuthProvider>().uploadProfilePhoto(
          image.path,
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? 'Foto de perfil actualizada correctamente.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openProfileForm(
    BuildContext context,
    UsuarioAuth? usuario,
  ) async {
    if (usuario == null) {
      return;
    }

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
          value: context.read<AuthProvider>(),
          child: ProfileFormSheet(usuario: usuario),
        );
      },
    );
  }
}
