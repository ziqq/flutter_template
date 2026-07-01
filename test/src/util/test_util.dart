// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:io' as io;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart' show BuildContext, Widget, Placeholder, WidgetBuilder, Locale, Size, Builder;
import 'package:flutter_template_name/src/app.dart' show App;
import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/database/database.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/feature/authentication/data/authentication_repository.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/authentication_scope.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/app_settings_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/data/providers/user_preferences_data_provider.dart';
import 'package:flutter_template_name/src/feature/settings/data/settings_repository.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui/ui.dart' show UIThemeData, MaterialApp, Material;

export 'fixture.dart';
export 'mocks/_all.dart';
export 'test_util.mocks.dart';

@GenerateNiceMocks([
  //
  // Common
  //
  MockSpec<FirebaseMessaging>(),
  MockSpec<SharedPreferencesAsync>(),
  MockSpec<SimpleSelectStatement>(), // ignore: strict_raw_type
  MockSpec<InsertStatement>(), // ignore: strict_raw_type
  MockSpec<ApiClient$HTTP>(),
  MockSpec<Database>(),
  MockSpec<io.File>(),
  //
  // Authentication
  //
  MockSpec<AuthenticationRepository>(),
  //
  // Settings
  //
  MockSpec<SettingsRepository>(),
  MockSpec<AppSettingsDataProvider>(),
  MockSpec<UserPreferencesDataProvider>(),
])
void mocks() {}

/// Example for use it:
/// ```dart
/// testWidgets('description for test',
///   (WidgetTester t) async {
///     await t.pumpWidget(
///       WidgetTestUtil.createWidgetUnderTest(child: const AuthView())
///     );
///
///     final WidgetTestResult result = await WidgetTestUtil.getLocalizationsAndContextUnderTests(t);
///     final BuildContext result = await WidgetTestUtil.getContextUnderTest(t);
///     final String text =
///                  await WidgetTestUtil.getLocalizationsUnderTests(t)
///                  .then((l) => l.actionSignIn);
///
///     expect(find.text(text), findsOneWidget);
///   },
/// );
/// ```

@isTestGroup
class WidgetTestUtil {
  const WidgetTestUtil._();

  /// Helper method to get both localizations and context under test.
  static Future<WidgetTestResult> getLocalizationsAndContextUnderTests(WidgetTester t) async {
    late WidgetTestResult result;
    await t.pumpWidget(
      MaterialApp(
        localizationsDelegates: App.localizationsDelegates,
        supportedLocales: /* Locales.values */ Localization.supportedLocales,
        locale: Config.locale,
        home: Material(
          child: Builder(
            builder: (context) {
              result = WidgetTestResult(localizations: Localization.of(context), context: context);

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

  /// Helper method to get only context under test.
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

  /// Helper method to create a widget under test with the necessary context, localization and theme.
  /// [builder] is a widget builder that will be used to build the widget under test.
  /// [locale] is the locale that will be used for localization.
  static Widget createWidgetUnderTest({
    required WidgetBuilder builder,
    Locale locale = Config.locale,
    Dependencies? dependencies,
  }) => MaterialApp(
    localizationsDelegates: App.localizationsDelegates,
    supportedLocales: /* Locales.values */ Localization.supportedLocales,
    locale: locale,
    theme: UIThemeData.light(),
    darkTheme: UIThemeData.dark(),
    home: Builder(
      builder: (context) => dependencies != null
          ? InheritedDependencies(
              dependencies: dependencies,
              child: SettingsScope(child: AuthenticationScope(child: builder(context))),
            )
          : builder(context),
    ),
  );

  /// Helper method to create a widget under test with the necessary context and dependencies.
  /// [dependencies] is the dependencies that will be used for the widget under test.
  /// [builder] is a widget builder that will be used to build the widget under test.
  /// [size] is the size of the widget under test.
  static Widget appContext({required Dependencies dependencies, required WidgetBuilder builder, Size? size}) => Builder(
    builder: (context) => InheritedDependencies(
      dependencies: dependencies,
      child: SettingsScope(child: AuthenticationScope(child: builder(context))),
    ),
  );
}

@immutable
@isTest
class WidgetTestResult {
  const WidgetTestResult({required this.localizations, required this.context});

  final Localization localizations;
  final BuildContext context;

  @override
  String toString() => 'WidgetTestResult{languageCode: ${localizations.locale.languageCode}, context: $context}';
}
