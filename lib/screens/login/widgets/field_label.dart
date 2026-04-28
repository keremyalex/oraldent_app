import 'package:flutter/material.dart';
import 'package:odontologia_app/theme/app_colors.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel({
    required this.label,
    required this.child,
    super.key,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.inverted,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
