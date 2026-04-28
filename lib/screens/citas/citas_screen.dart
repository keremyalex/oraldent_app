import 'package:flutter/material.dart';
import 'package:odontologia_app/models/cita.dart';
import 'package:odontologia_app/providers/auth_provider.dart';
import 'package:odontologia_app/providers/citas_provider.dart';
import 'package:odontologia_app/providers/pacientes_provider.dart';
import 'package:odontologia_app/providers/servicios_provider.dart';
import 'package:odontologia_app/screens/citas/widgets/cita_form_sheet.dart';
import 'package:odontologia_app/screens/citas/widgets/cita_timeline_card.dart';
import 'package:odontologia_app/screens/citas/widgets/citas_date_timeline.dart';
import 'package:odontologia_app/screens/citas/widgets/citas_header.dart';
import 'package:odontologia_app/screens/citas/widgets/citas_message.dart';
import 'package:odontologia_app/theme/app_colors.dart';
import 'package:odontologia_app/widgets/app_back_guard.dart';
import 'package:odontologia_app/widgets/app_bottom_navigation.dart';
import 'package:provider/provider.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
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
        context.read<CitasProvider>().load();
        context.read<PacientesProvider>().load();
        context.read<ServiciosProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final citasProvider = context.watch<CitasProvider>();
    final auth = context.watch<AuthProvider>();
    final textTheme = Theme.of(context).textTheme;

    return DashboardBackGuard(
      child: Scaffold(
        backgroundColor: AppColors.neutral,
        bottomNavigationBar: const AppBottomNavigation(
          currentTab: AppTab.appointments,
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: CitasHeader(
                    userRole: auth.usuario?.rol ?? 'Staff',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: CitasDateTimeline(
                    selectedDate: citasProvider.selectedDate,
                    onDateChange: (date) {
                      context.read<CitasProvider>().load(date: date);
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateTitle(citasProvider.selectedDate),
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 23,
                          color: AppColors.inverted,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => context.read<CitasProvider>().load(),
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
              if (citasProvider.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (citasProvider.errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: CitasMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'No se pudieron cargar las citas',
                    message: citasProvider.errorMessage!,
                    actionLabel: 'Reintentar',
                    onAction: () => context.read<CitasProvider>().load(),
                  ),
                )
              else if (citasProvider.citas.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: CitasMessage(
                    icon: Icons.event_busy_rounded,
                    title: 'No hay citas para esta fecha',
                    message: 'Selecciona otro dia o registra una nueva cita.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList.separated(
                    itemCount: citasProvider.citas.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cita = citasProvider.citas[index];
                      return CitaTimelineCard(
                        cita: cita,
                        onTap: () => _openCitaForm(context, cita),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openCitaForm(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  String _dateTitle(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _months[date.month - 1];
    return '$day de $month';
  }

  Future<void> _openCitaForm(BuildContext context, [Cita? cita]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<CitasProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<PacientesProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<ServiciosProvider>(),
            ),
          ],
          child: CitaFormSheet(cita: cita),
        );
      },
    );
  }
}

const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];
