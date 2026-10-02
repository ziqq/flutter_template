/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 03 August 2026
 */

import 'package:flutter/cupertino.dart' show CupertinoPageTransition, CupertinoRouteTransitionMixin;
import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/router/transitions_builder.dart';

final class _MaterialPageRoute<T> extends PageRoute<T> with MaterialRouteTransitionMixin<T> {
  _MaterialPageRoute({
    required this.customBarrierColor,
    required this.customOpaque,
    required this.builder,
    required super.fullscreenDialog,
    required super.settings,
  });

  final Color? customBarrierColor;
  final bool customOpaque;
  final WidgetBuilder builder;

  @override
  Color? get barrierColor => customBarrierColor;

  @override
  bool get opaque => customOpaque;

  @override
  bool get maintainState => true;

  @override
  Widget buildContent(BuildContext context) => builder(context);
}

final class _CupertinoPageRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  _CupertinoPageRoute({
    required this.customBarrierColor,
    required this.customOpaque,
    required this.builder,
    required super.fullscreenDialog,
    required super.settings,
  });

  final Color? customBarrierColor;
  final bool customOpaque;
  final WidgetBuilder builder;

  @override
  Color? get barrierColor => customBarrierColor;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => customOpaque;

  @override
  String? get title => null;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      fullscreenDialog ? null : CupertinoPageTransition.delegatedTransition;

  @override
  bool canTransitionFrom(TransitionRoute<Object?> previousRoute) => !fullscreenDialog;
}

/// A reusable declarative navigation page with optional deep-link and overlay metadata.
///
/// Feature and application packages should extend this type with `base`, `final`,
/// or `sealed` page classes. The page is intentionally independent from concrete
/// route parsers, screens, analytics, and application scopes.
@immutable
base class AppPage extends MaterialPage<void> {
  /// Creates a navigation page with stable identity and optional restoration metadata.
  ///
  /// The inherited `name` and [key] identify the route for diagnostics and page
  /// equality. [path] may describe a restorable route pattern independently of
  /// that diagnostic name.
  const AppPage({
    required String super.name,
    required Map<String, Object?>? super.arguments,
    required super.child,
    required LocalKey super.key,
    this.path,
    this.barrierColor,
    this.opaque = true,
    super.fullscreenDialog,
  });

  /// The optional deep-link or restoration pattern represented by this page.
  final String? path;

  /// Whether this route fully obscures the route below it.
  final bool opaque;

  /// The optional modal barrier color used by overlay-style pages.
  ///
  /// Setting a barrier color causes [createRoute] to build a route that preserves
  /// the requested [opaque] value and platform transition.
  final Color? barrierColor;

  @override
  String get name => super.name ?? 'unknown';

  @override
  Map<String, Object?>? get arguments => switch (super.arguments) {
    Map<String, Object?> args when args.isNotEmpty => args,
    _ => const <String, Object?>{},
  };

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppPage && other.key == key;

  /// Creates the platform route for this page.
  ///
  /// Opaque pages without a custom barrier use Flutter's normal [MaterialPage]
  /// route. Overlay pages retain the platform transition while applying [opaque]
  /// and [barrierColor].
  @override
  Route<void> createRoute(BuildContext context) {
    if (opaque && barrierColor == null) return super.createRoute(context);
    return switch (Theme.of(context).platform) {
      .iOS || .macOS => _CupertinoPageRoute<void>(
        fullscreenDialog: fullscreenDialog,
        customBarrierColor: barrierColor,
        customOpaque: opaque,
        settings: this,
        builder: (_) => child,
      ),
      _ => _MaterialPageRoute<void>(
        fullscreenDialog: fullscreenDialog,
        customBarrierColor: barrierColor,
        customOpaque: opaque,
        settings: this,
        builder: (_) => child,
      ),
    };
  }
}

/// An [AppPage] that fades into view.
@immutable
base class AppPage$Fade extends AppPage {
  /// Creates a fading route page.
  const AppPage$Fade({
    required super.child,
    required super.name,
    required super.key,
    super.arguments,
    super.path,
    super.opaque,
    super.barrierColor,
    super.fullscreenDialog = true,
    this.duration = const Duration(milliseconds: 350),
  });

  /// The fade transition duration.
  final Duration duration;

  @override
  Route<Object?> createRoute(BuildContext context) => PageRouteBuilder<Object?>(
    settings: this,
    opaque: opaque,
    barrierColor: barrierColor,
    fullscreenDialog: fullscreenDialog,
    transitionDuration: duration,
    transitionsBuilder: TransitionsBuilder.fade,
    pageBuilder: (context, animation, secondaryAnimation) => child,
  );
}

/// An [AppPage] that slides upward from the bottom edge.
@immutable
base class AppPage$SlideFromBottom extends AppPage {
  /// Creates a bottom-up sliding route page.
  const AppPage$SlideFromBottom({
    required super.child,
    required super.name,
    required super.key,
    super.arguments,
    super.path,
    super.opaque,
    super.barrierColor,
    super.fullscreenDialog = true,
    this.duration = const Duration(milliseconds: 250),
  });

  /// The slide transition duration.
  final Duration duration;

  @override
  Route<Object?> createRoute(BuildContext context) => PageRouteBuilder<Object?>(
    settings: this,
    opaque: opaque,
    barrierColor: barrierColor,
    fullscreenDialog: fullscreenDialog,
    transitionDuration: duration,
    transitionsBuilder: TransitionsBuilder.slideBottom,
    pageBuilder: (context, animation, secondaryAnimation) => child,
  );
}
