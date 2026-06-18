/*
 * Date: 05 May 2025
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:ui/ui.dart';

/// {@template common_back_button}
/// CommonBackButton widget.
/// {@endtemplate}
class CommonBackButton extends StatelessWidget {
  /// {@macro common_back_button}
  const CommonBackButton({
    this.previousPageTitle,
    this.onPressed,
    this.color,
    super.key, // ignore: unused_element_parameter
  });

  /// The color of the icon of button.
  final Color? color;

  /// The title of the previous page.
  final String? previousPageTitle;

  /// The callback that is called when the button is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => CupertinoNavigationBarBackButton(
    color: color ?? Theme.of(context).uiTheme.color.text,
    previousPageTitle: previousPageTitle ?? '',
    onPressed: onPressed ?? context.ext.navigator.pop,
  );
}
