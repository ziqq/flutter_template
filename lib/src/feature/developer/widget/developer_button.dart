import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/feature/developer/widget/logs_screen.dart';

/// {@template developer_button}
/// DeveloperButton widget
/// {@endtemplate}
class DeveloperButton extends StatelessWidget {
  /// {@macro developer_button}
  const DeveloperButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.developer_mode),
    tooltip: 'Developer',
    onPressed: () => LogsScreen.show(context),
  );
}
