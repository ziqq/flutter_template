import 'package:flutter/cupertino.dart' show kCupertinoModalBarrierColor, CupertinoDynamicColor;
import 'package:flutter_template_name/src/common/router/app_route_parser.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/signup_screen.dart';
import 'package:flutter_template_name/src/feature/developer/developer_screens.dart';
import 'package:flutter_template_name/src/feature/home/widget/home_screen.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart'
    show
        MaterialPage,
        LocalKey,
        ValueKey,
        Route,
        Color,
        BuildContext,
        Offset,
        PageRouteBuilder,
        Curves,
        CurvedAnimation,
        FadeTransition,
        Tween,
        SlideTransition,
        UISheetRoute;

/// {@template page}
/// A custom page class that extends [Page] to represent a page in the app's navigation stack.
/// {@endtemplate}
@immutable
sealed class AppPage extends MaterialPage<void> {
  /// Creates a new instance of [AppPage].
  /// {@macro page}
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

  /// The path associated with this page,
  /// used for deep linking or route matching.
  final String? path;

  /// Whether the route obscures previous routes when pushed.
  final bool opaque;

  /// The modal barrier color for overlay-style pages.
  final Color? barrierColor;

  @override
  String get name => super.name ?? 'Unknown';

  @override
  Map<String, Object?>? get arguments => switch (super.arguments) {
    Map<String, Object?> args when args.isNotEmpty => args,
    _ => const <String, Object?>{},
  };

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AppPage && other.key == key;

  @override
  Route<void> createRoute(BuildContext context) {
    if (opaque && barrierColor == null) return super.createRoute(context);

    return PageRouteBuilder<void>(
      settings: this,
      opaque: opaque,
      barrierColor: barrierColor,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    );
  }

  /// Creates an [AppPage] instance from a given route string.
  ///
  /// Example:
  /// ```dart
  /// final page = AppPage.fromRoute('/analytics');
  /// if (page != null) {
  ///  // Navigate to the page
  ///  AppNavigator.of(context).push(page);
  /// }
  /// ```
  ///
  /// See the docs: `flutter_template_name/docs/common/navigation.md`
  static AppPage? fromRoute(String route) {
    final parsedPage = AppRouteParser.parse(route).pageOrNull;
    l.i('Parsing route: $route, parsed page: ${parsedPage?.name ?? 'null'}');
    return parsedPage;
  }
}

/// A page that fades in its child.
/// {@macro page}
@immutable
class AppPage$Fade extends AppPage {
  /// {@macro page}
  const AppPage$Fade({
    required super.child,
    required super.name,
    required super.key,
    super.arguments,
    super.path,
    super.opaque,
    super.barrierColor,
    this.duration = const Duration(milliseconds: 350),
  });

  /// The duration of the fade transition.
  final Duration duration;

  @override
  Route<Object?> createRoute(BuildContext context) => PageRouteBuilder(
    settings: this,
    opaque: opaque,
    barrierColor: barrierColor,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      return FadeTransition(opacity: fade, child: child);
    },
  );
}

/// A page that slides in its child from the bottom.
/// {@macro page}
@immutable
class AppPage$SlideFromBottom extends AppPage {
  /// {@macro page}
  const AppPage$SlideFromBottom({
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

  /// The duration of the slide transition.
  final Duration duration;

  @override
  Route<Object?> createRoute(BuildContext context) => PageRouteBuilder(
    settings: this,
    opaque: opaque,
    barrierColor: barrierColor,
    fullscreenDialog: fullscreenDialog,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(slide),
        child: child,
      );
    },
  );
}

/// A page that shows its child in a bottom sheet style.
@immutable
class AppPage$Sheet extends AppPage {
  /// {@macro page}
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

/// SignUp page.
final class SignUpPage extends AppPage {
  const SignUpPage()
    : super(arguments: null, name: 'sign-up', child: const SignUpScreen(), key: const ValueKey<String>('sign_up'));
}

/// Developer page.
final class DeveloperPage extends AppPage {
  const DeveloperPage()
    : super(
        arguments: null,
        name: 'developer',
        child: const DeveloperScreen(),
        key: const ValueKey<String>('developer'),
      );
}

/// Developer info page.
final class DeveloperInfoPage extends AppPage {
  const DeveloperInfoPage()
    : super(
        arguments: null,
        name: 'developer-info',
        child: const DeveloperInfoScreen(),
        key: const ValueKey<String>('developer_info'),
      );
}

/// Home page.
final class HomePage extends AppPage {
  const HomePage()
    : super(arguments: null, name: 'home', child: const HomeScreen(), key: const ValueKey<String>('home'));
}
