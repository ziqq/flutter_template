/*
 * Date: 04 June 2026
 */

import 'dart:math' as math;

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:ui/ui.dart';

/// {@template common_padding}
/// CommonPadding widget.
/// {@endtemplate}
class CommonPadding extends EdgeInsets {
  /// {@macro common_padding}
  const CommonPadding._(final double value) : super.symmetric(horizontal: value);

  /// {@macro common_padding}
  factory CommonPadding.of(BuildContext context) => CommonPadding._(
    math.max((MediaQuery.sizeOf(context).width - Config.maxScreenLayoutWidth) / 2, Theme.of(context).uiTheme.padding),
  );

  /// {@macro common_padding}
  static Widget widget(BuildContext context, [Widget? child]) =>
      Padding(padding: CommonPadding.of(context), child: child);

  /// {@macro common_padding}
  static Widget sliver(BuildContext context, [Widget? child]) =>
      SliverPadding(padding: CommonPadding.of(context), sliver: child);
}
