import 'dart:async';
import 'dart:developer' as dev;

import 'package:example/src/catalog/catalog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ui/ui.dart';

/// Holds the catalog theme for the example's process lifetime.
final themeModeSwitcher = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Compares the standard and Rive renderers without application preferences.
final operationStatusIndicatorStyleSwitcher = ValueNotifier<UIOperationStatusIndicatorStyle>(
  UIOperationStatusIndicatorStyle.standard,
);

void main() => runZonedGuarded<void>(
  () => runApp(const UIExampleApp()),
  (error, stackTrace) => dev.log(
    'Top level exception: $error\nstackTrace: $stackTrace',
    error: error,
    stackTrace: stackTrace,
    level: 1000,
  ),
);

/// Configures the public UI themes, localization, and responsive catalog.
class UIExampleApp extends StatelessWidget {
  const UIExampleApp({this.controller, super.key});

  /// Legacy caller-owned page controller retained for existing example callers.
  ///
  /// The catalog itself uses the SDK Navigator for temporary preview routes.
  final ValueNotifier<List<Page<Object?>>>? controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: themeModeSwitcher,
    builder: (context, themeMode, _) => MaterialApp(
      title: 'UI KIT',
      theme: UIThemeData.light(),
      darkTheme: UIThemeData.dark(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        UILocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (_, child) => ValueListenableBuilder<UIOperationStatusIndicatorStyle>(
        valueListenable: operationStatusIndicatorStyleSwitcher,
        child: child,
        builder: (_, indicatorStyle, child) =>
            UIScope(operationStatusIndicatorStyle: indicatorStyle, child: child ?? const SizedBox.shrink()),
      ),
      home: const UIPreview(),
    ),
  );
}

/// Connects the catalog's theme action to the process-local theme selection.
class UIPreview extends StatelessWidget {
  const UIPreview({super.key});

  @override
  Widget build(BuildContext context) => CatalogScreen(
    onToggleTheme: () =>
        themeModeSwitcher.value = Theme.of(context).brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light,
  );
}
