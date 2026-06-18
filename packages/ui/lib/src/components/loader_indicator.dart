// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/cupertino.dart';
import 'package:platform_info/platform_info.dart';
import 'package:ui/ui.dart';

/// {@template loader_indicator}
/// UILoaderIndicator widget.
/// {@endtemplate}
class UILoaderIndicator extends StatelessWidget {
  /// {@macro loader_indicator}
  const UILoaderIndicator({
    this.text,
    this.color,
    this.value,
    this.radius = 10,
    this.adaptive = true,
    this.strokeWidth = 3.0,
    super.key,
  }) : _withText = false;

  /// {@macro loader_indicator}
  const UILoaderIndicator.text({
    this.text,
    this.color,
    this.value,
    this.radius = 10,
    this.adaptive = true,
    this.strokeWidth = 3.0,
    super.key,
  }) : _withText = true;

  /// Use adaptive to platform loader?
  final bool adaptive;

  /// The radius.
  final double radius;

  /// The stroke width.
  final double strokeWidth;

  /// The value.
  final double? value;

  /// The text.
  final String? text;

  /// The color.
  final Color? color;

  /// With text?
  final bool _withText;

  @override
  Widget build(BuildContext context) => _withText
      ? Column(
          mainAxisAlignment: .center,
          children: <Widget>[
            Center(
              child: _UILoaderIndicator$Indicator(
                strokeWidth: strokeWidth,
                adaptive: adaptive,
                radius: radius,
                value: value,
                color: color,
              ),
            ),
            SizedBox(height: platform.android ? 10 : 5),
            Text(
              text?.toUpperCase() ?? '${UILocalizations.of(context).loading}...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        )
      : _UILoaderIndicator$Indicator(
          strokeWidth: strokeWidth,
          adaptive: adaptive,
          radius: radius,
          value: value,
          color: color,
        );
}

/// {@template loader_indicator}
/// CustomLoaderIndecator widget.
/// {@endtemplate}
class _UILoaderIndicator$Indicator extends StatelessWidget {
  /// {@macro loader_indicator}_indicator}
  const _UILoaderIndicator$Indicator({
    this.color,
    this.value,
    this.radius = 10,
    this.adaptive = true,
    this.strokeWidth = 3.0,
    super.key, // ignore: unused_element_parameter
  });

  final bool adaptive;
  final double radius;
  final double strokeWidth;
  final double? value;
  final Color? color;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    key: const ValueKey<String>('loader_indicator'),
    child: platform.iOS || !adaptive
        ? CupertinoActivityIndicator(radius: radius, color: color)
        : SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(color ?? Theme.of(context).uiTheme.color.accent),
            ),
          ),
  );
}
