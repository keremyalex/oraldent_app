import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odontologia_app/theme/app_colors.dart';

enum AppTab { appointments, patients, settings }

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentTab,
    super.key,
  });

  final AppTab currentTab;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentTab.index,
      height: 72,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.10),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: 'Citas',
        ),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group_rounded),
          label: 'Pacientes',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Ajustes',
        ),
      ],
      onDestinationSelected: (index) {
        final selectedTab = AppTab.values[index];
        if (selectedTab == currentTab) {
          return;
        }

        switch (selectedTab) {
          case AppTab.appointments:
            context.go('/citas');
          case AppTab.patients:
            context.go('/pacientes');
          case AppTab.settings:
            context.go('/ajustes');
        }
      },
    );
  }
}
