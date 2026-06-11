import 'package:flutter/material.dart';

class FichaTabScaffold extends StatelessWidget {
  const FichaTabScaffold({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
      children: children,
    );
  }
}
