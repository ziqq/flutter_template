import 'package:flutter/cupertino.dart' show CupertinoDynamicColor, kCupertinoModalBarrierColor;
import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/router/page.dart';
import 'package:ui/ui.dart' show UISheetRoute;

/// A page that shows its child in a bottom sheet style.
@immutable
base class AppPage$Sheet extends AppPage {
  /// Creates a draggable sheet page with application-owned content.
  const AppPage$Sheet({
    required super.child,
    required super.name,
    required super.key,
    super.arguments,
    super.path,
    super.opaque,
    super.barrierColor,
    this.draggable = true,
  });

  /// Whether the sheet can be dragged by the user.
  final bool draggable;

  @override
  Route<Object?> createRoute(BuildContext context) => UISheetRoute<void>(
    barrierColor: barrierColor ?? CupertinoDynamicColor.resolve(kCupertinoModalBarrierColor, context),
    callNavigatorUserGestureMethods: true,
    draggable: draggable,
    settings: this,
    child: child,
  );
}
