import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/models/paciente.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/providers/pacientes_provider.dart';
import 'package:odontologia_app/screens/pacientes/widgets/paciente_card.dart';
import 'package:odontologia_app/screens/pacientes/widgets/paciente_form_sheet.dart';
import 'package:odontologia_app/screens/pacientes/widgets/pacientes_header.dart';
import 'package:odontologia_app/screens/pacientes/widgets/pacientes_message.dart';
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
                  child: PacientesHeader(
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
                                context.read<PacientesProvider>().updateQuery(
                                  '',
                                );
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
                        onPressed: () =>
                            context.read<PacientesProvider>().load(),
                        icon: const Icon(Icons.refresh_rounded),
                        color: AppColors.primary,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.08,
                          ),
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
                  child: PacientesMessage(
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
                  child: PacientesMessage(
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
                      return PacienteCard(
                        paciente: pacientes[index],
                        onTap: () =>
                            _openPacienteForm(context, pacientes[index]),
                        onOdontogramaTap: () => context.push(
                          '/pacientes/${pacientes[index].id}/odontograma',
                          extra: pacientes[index],
                        ),
                        onPeriodontogramaTap: () => context.push(
                          '/pacientes/${pacientes[index].id}/periodontograma',
                          extra: pacientes[index],
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
          child: PacienteFormSheet(paciente: paciente),
        );
      },
    );
  }
}
