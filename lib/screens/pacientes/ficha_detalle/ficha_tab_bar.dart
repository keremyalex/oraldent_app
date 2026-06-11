import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class FichaTabData {
  const FichaTabData(this.label, this.icon);

  final String label;
  final Object icon;
}

class FichaTabBar extends StatelessWidget {
  const FichaTabBar({required this.controller, required this.tabs, super.key});

  final TabController controller;
  final List<FichaTabData> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.neutral,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFE7F4EE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD5E7DE)),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.secondary,
          labelStyle: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          unselectedLabelStyle: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          tabs: [
            for (final tab in tabs)
              Tab(
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClinicalIcon(icon: tab.icon, size: 16),
                      const SizedBox(width: 8),
                      Text(tab.label),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ClinicalIcon extends StatelessWidget {
  const ClinicalIcon({required this.icon, this.color, this.size, super.key});

  final Object icon;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final iconValue = icon;
    if (iconValue is FaIconData) {
      return FaIcon(iconValue, color: color, size: size);
    }
    return Icon(iconValue as IconData, color: color, size: size);
  }
}
