import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/usuario_auth.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:odontologia_app/widgets/app_back_guard.dart';
import 'package:odontologia_app/widgets/app_bottom_navigation.dart';
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
                  child: _SettingsHeader(
                    onHome: () => context.go('/dashboard'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: _ProfileCard(
                    usuario: auth.usuario,
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
                    _SettingsOptionCard(
                      icon: Icons.schedule_rounded,
                      title: 'Horario de atencion',
                      subtitle: 'Dias, bloques y duracion de cada cita',
                      onTap: () => context.push('/ajustes/horarios'),
                    ),
                    const SizedBox(height: 12),
                    _SettingsOptionCard(
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
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({
    required this.onHome,
  });

  final VoidCallback onHome;

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
                'Ajustes',
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 32,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Perfil y configuracion',
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onHome,
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.usuario,
    required this.onLogout,
  });

  final UsuarioAuth? usuario;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = usuario;
    final initials = user == null
        ? 'AD'
        : '${user.nombre[0]}${user.apellidoPaterno[0]}'.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: user?.fotoPerfilUrl == null ||
                        user!.fotoPerfilUrl!.isEmpty
                    ? Center(
                        child: Text(
                          initials,
                          style: textTheme.displayLarge?.copyWith(
                            color: AppColors.primary,
                            fontSize: 22,
                          ),
                        ),
                      )
                    : Image.network(
                        user.fotoPerfilUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              initials,
                              style: textTheme.displayLarge?.copyWith(
                                color: AppColors.primary,
                                fontSize: 22,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.nombreCompleto ?? 'Administrador',
                      style: textTheme.displayLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.rol ?? 'ADMIN',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileRow(
            icon: Icons.mail_outline_rounded,
            label: user?.correo ?? 'Sin correo',
          ),
          const SizedBox(height: 10),
          _ProfileRow(
            icon: Icons.phone_rounded,
            label: user?.celular ?? 'Sin celular',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesion'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _SettingsOptionCard extends StatelessWidget {
  const _SettingsOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.inverted,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
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
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
