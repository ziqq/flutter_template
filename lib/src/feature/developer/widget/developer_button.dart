import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/router/app_pages.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';

/// {@template developer_button}
/// DeveloperButton widget
/// {@endtemplate}
class DeveloperButton extends StatelessWidget {
  /// {@macro developer_button}
  const DeveloperButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.developer_mode),
    tooltip: Localization.of(context).developerTitle,
    onPressed: () => context.ext.navigator.push(const DeveloperPage()),
  );
}
