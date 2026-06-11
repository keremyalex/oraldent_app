import 'package:flutter/material.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class FichaSectionCard extends StatelessWidget {
  const FichaSectionCard({
    required this.title,
    required this.icon,
    required this.children,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.inverted,
            fontWeight: FontWeight.w800,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        children: [
          for (final child in children) ...[child, const SizedBox(height: 12)],
        ],
      ),
    );
  }
}
