import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:example/src/widgets/buttons_preview.dart';
import 'package:example/src/widgets/icons_preview.dart';
import 'package:example/src/widgets/typography_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ui/ui.dart';

/// A [ValueNotifier] to switch the [ThemeMode] of the app.
final themeModeSwitcher = ValueNotifier(ThemeMode.system);

/// The main entry point of the ui example.
void main() => runZonedGuarded<void>(
  () => runApp(UIExampleApp(controller: ValueNotifier<List<Page<Object?>>>([]))),
  (error, stackTrace) => dev.log(
    'Top level exception: $error\nstackTrace: $stackTrace',
    error: error,
    stackTrace: stackTrace,
    level: 1000,
  ),
);

/// The main ui example app widget.
class UIExampleApp extends StatelessWidget {
  const UIExampleApp({required this.controller, super.key});

  final ValueNotifier<List<Page<Object?>>> controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: themeModeSwitcher,
    builder: (context, themeMode, _) => MaterialApp(
      title: 'UI KIT',
      theme: AppThemeData.light(),
      darkTheme: AppThemeData.dark(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      themeMode: themeMode,
      home: const UIPreview(),
    ),
  );
}

/// The main preview widget that shows all the components of the UI kit.
class UIPreview extends StatelessWidget {
  const UIPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    const spacerVertical = SliverToBoxAdapter(child: SizedBox(height: 16));
    final backgroundColor = brightness == Brightness.dark
        ? CupertinoColors.systemBackground
        : CupertinoColors.secondarySystemBackground;
    return Scaffold(
      backgroundColor: CupertinoDynamicColor.resolve(backgroundColor, context),
      body: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: EdgeInsets.symmetric(horizontal: math.max((constraints.maxWidth - 900) / 2, 16), vertical: 16 * 1.5),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                centerTitle: false,
                backgroundColor: CupertinoDynamicColor.resolve(backgroundColor, context),
                foregroundColor: CupertinoDynamicColor.resolve(backgroundColor, context),
                surfaceTintColor: CupertinoDynamicColor.resolve(backgroundColor, context),
                title: Text('UI KIT', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                actions: [
                  CupertinoButton(
                    child: brightness == Brightness.light
                        ? const Icon(Icons.dark_mode_rounded)
                        : const Icon(Icons.light_mode_rounded),
                    onPressed: () {
                      HapticFeedback.heavyImpact().ignore();
                      themeModeSwitcher.value = brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ],
              ),

              // --- Icon's --- //
              const UIIconsPreview$LeafRenderObject(),
              spacerVertical,

              // const UIIconsPreview.font(),
              // spacerVertical,

              // --- Button's --- //
              const UIButtonsPreview(),
              spacerVertical,

              // --- App Colors --- //
              // const UIColorsPreview(),
              // spacerVertical,

              // --- Typography --- //
              const TypographyPreview(),
            ],
          ),
        ),
      ),
    );
  }
}
