import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/cita.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/providers/dashboard_provider.dart';
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
                child: _DashboardHeader(
                  textTheme: textTheme,
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
                      child: _MetricCard(
                        icon: Icons.event_available_rounded,
                        label: 'Citas registradas',
                        value: dashboard.citasCount.toString(),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _MetricCard(
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
                child: _DashboardMessage(
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
                child: _DashboardMessage(
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
                    return _AppointmentCard(cita: dashboard.citas[index]);
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.textTheme,
    required this.userName,
    required this.role,
    required this.onLogout,
  });

  final TextTheme textTheme;
  final String userName;
  final String role;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 32,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$userName • $role',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: onLogout,
            color: AppColors.primary,
            icon: const Icon(Icons.logout_rounded),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: textTheme.displayLarge?.copyWith(
              fontSize: 30,
              color: AppColors.inverted,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.cita,
  });

  final Cita cita;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _statusColor(cita.estado);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  cita.paciente.initials,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cita.paciente.nombreCompleto,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.inverted,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cita.tituloServicio,
                    maxLines: 1,
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
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  cita.hora,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.inverted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    _statusLabel(cita.estado),
                    style: textTheme.labelLarge?.copyWith(
                      color: color,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'CONFIRMADA' => AppColors.tertiary,
      'PENDIENTE' => AppColors.primary,
      'REPROGRAMADA' => const Color(0xFF505F76),
      'ATENDIDA' => const Color(0xFF00786B),
      'CANCELADA' || 'NO_ASISTIO' => const Color(0xFFBA1A1A),
      _ => AppColors.primary,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'CONFIRMADA' => 'Confirmada',
      'PENDIENTE' => 'Pendiente',
      'REPROGRAMADA' => 'Reprogramada',
      'ATENDIDA' => 'Atendida',
      'CANCELADA' => 'Cancelada',
      'NO_ASISTIO' => 'No asistio',
      _ => status,
    };
  }
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({
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
