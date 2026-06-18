// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_template_name/src/app.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/localization/localization_overrides.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

/// Example for use it:
/// ```dart
/// testWidgets('description for test',
///   (WidgetTester t) async {
///     await t.pumpWidget(
///       IntegrationTestHelper.createWidgetUnderTest(child: const AuthView())
///     );
///
///     final IntegrationTestResult result =
///         await IntegrationTestHelper.getLocalizationsAndContextUnderTests(t);
///
///     final BuildContext result =
///         await IntegrationTestHelper.getContextUnderTest(t);
///
///     final String text =
///         await IntegrationTestHelper.getLocalizationsUnderTests(t)
///         .then((l) => l.actionSignIn);
///
///     expect(find.text(text), findsOneWidget);
///   },
/// );
/// ```

@isTestGroup
class IntegrationTestHelper {
  const IntegrationTestHelper._();

  @isTest
  static Future<IntegrationTestResult> getLocalizationsAndContextUnderTests(WidgetTester t) async {
    late IntegrationTestResult result;
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: App.localizationsDelegates,
        supportedLocales: Localization.supportedLocales,
        locale: Config.locale,
        home: Material(
          child: Builder(
            builder: (context) {
              result = IntegrationTestResult(localizations: Localization.of(context), context: context);

              // The builder function must return a widget.
              return const Placeholder();
            },
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    return result;
  }

  @isTest
  static Future<BuildContext> getContextUnderTest(WidgetTester t) async {
    late BuildContext result;
    await t.pumpWidget(
      Builder(
        builder: (context) {
          result = context;

          // The builder function must return a widget.
          return const Placeholder();
        },
      ),
    );
    return result;
  }

  @isTest
  static Widget createWidgetUnderTest({Widget? child}) => MaterialApp(
    localizationsDelegates: const [
      GlobalCupertinoLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      OverrideUILocalizations.delegate,
      Localization.delegate,
      Localization.delegate,
    ],
    locale: Config.locale,
    home: child,
  );
}

class IntegrationTestResult {
  IntegrationTestResult({required this.localizations, required this.context});
  final Localization localizations;
  final BuildContext context;
}
