import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/providers/dashboard_provider.dart';
import 'package:odontologia_app/screens/dashboard/widgets/appointment_card.dart';
import 'package:odontologia_app/screens/dashboard/widgets/dashboard_header.dart';
import 'package:odontologia_app/screens/dashboard/widgets/dashboard_message.dart';
import 'package:odontologia_app/screens/dashboard/widgets/metric_card.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:odontologia_app/widgets/app_back_guard.dart';
import 'package:odontologia_app/widgets/app_bottom_navigation.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
        context.read<DashboardProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dashboard = context.watch<DashboardProvider>();
    final auth = context.watch<AuthProvider>();

    return ExitConfirmGuard(
      child: Scaffold(
        backgroundColor: AppColors.neutral,
        bottomNavigationBar: const AppBottomNavigation(
          currentTab: AppTab.dashboard,
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: DashboardHeader(
                    userName: auth.usuario?.nombreCompleto ?? 'Personal',
                    role: auth.usuario?.rol ?? 'Staff',
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          icon: Icons.event_available_rounded,
                          label: 'Citas registradas',
                          value: dashboard.citasCount.toString(),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MetricCard(
                          icon: Icons.groups_rounded,
                          label: 'Pacientes activos',
                          value: dashboard.pacientesCount.toString(),
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Proximas citas',
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 24,
                          color: AppColors.inverted,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/citas'),
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                ),
              ),
              if (dashboard.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (dashboard.errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: DashboardMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'No se pudo cargar el dashboard',
                    message: dashboard.errorMessage!,
                    actionLabel: 'Reintentar',
                    onAction: () => context.read<DashboardProvider>().load(),
                  ),
                )
              else if (dashboard.citas.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: DashboardMessage(
                    icon: Icons.event_busy_rounded,
                    title: 'Sin citas registradas',
                    message: 'Cuando existan citas apareceran en esta lista.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList.separated(
                    itemCount: dashboard.citas.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return AppointmentCard(cita: dashboard.citas[index]);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
