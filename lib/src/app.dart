import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/app_navigator.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/common/widget/error_screen.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/bug_report/bug_report_util.dart';
import 'package:flutter_template_name/src/feature/bug_report/widget/bug_report_scope.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:flutter_template_name/src/scopes.dart';
import 'package:ui/ui.dart';

/// Stup supported locales for the application.
///
/// This class is used to define the supported locales for the application
/// and provide a convenient way to access them.
///
/// This calss can be replaced with the localization system of your choice,
/// but it is recommended to keep it as a single source of truth for supported locales in the application.
/* abstract final class Locales {
  const Locales._();

  static const Locale ru = Locale('ru');
  static const Locale en = Locale('en');

  static const List<Locale> values = [ru, en];
} */

/// {@template app}
/// Main App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  @override
  State<App> createState() => _AppState();

  /// Localizations delegates for the app.
  /// This list contains all the localization delegates used in the app.
  static const List<LocalizationsDelegate<Object>> localizationsDelegates = <LocalizationsDelegate<Object>>[
    // AppLocalization.delegate,
    // ErrorsLocalization.delegate,
    // TODO(ziqq): This delegat should be removed.
    // Anton Ustinoff <a.a.ustinoff@gmail.com>, 05 February 2026
    Localization.delegate,
    // The localization delegate from `flutter_simple_country_picker`
    // CountryLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

/// State for widget [App].
class _AppState extends State<App> {
  // This global key is needed for [MaterialApp]
  // to work properly when Widgets Inspector is enabled,
  // to disable recreate widget tree.
  static final Key _builderKey = GlobalKey(debugLabel: 'flutter_template_name');

  /// Internal observer to get the NavigatorState.
  NavigatorState? get navigator => _observer.navigator;
  final NavigatorObserver _observer = NavigatorObserver();

  /// Combined observers (including internal one).
  late List<NavigatorObserver> _observers;

  /// Current locale of the app.
  Locale? get locale => _locale;
  Locale? _locale;

  /// The main app navigator.
  late final AppNavigator _navigator;

  @override
  void initState() {
    super.initState();

    /// Add internal observer to the observers list.
    _observers = <NavigatorObserver>[_observer, AppNavigatorObserver(analytics: context.ext.dependencies.analytics)];

    /// Create navigator with [AppNavigator].
    _navigator = AppNavigator.controlled(
      controller: Dependencies.of(context).navigator,
      guards: const <AppNavigationState Function(BuildContext context, AppNavigationState state)>[
        /* AppNavigatorAnalyticsGuard(analytics: Dependencies.of(context).analytics), */
      ],
      observers: _observers,
      key: const ValueKey<String>('app_navigator'),
    );
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    _locale = Localization.supportedLocales.any((l) => l.languageCode == systemLocale.languageCode)
        ? systemLocale
        : Config.locale;
  }

  /* @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = SettingsScope.settingsOf(context, listen: false);
    final brightness = MediaQuery.platformBrightnessOf(context);
    final theme = switch (brightness) {
      .light => settings.theme.buildThemeData(Brightness.light),
      .dark => settings.theme.buildThemeData(Brightness.dark),
    };
    EasyLoading.instance
      ..backgroundColor = theme.uiTheme.color.snackbarBackgroundColor /* const .fromARGB(255, 11, 11, 11) */
      ..indicatorColor = theme.uiTheme.color.accent
      ..progressColor = theme.uiTheme.color.accent
      ..maskColor = theme.uiTheme.color.accent
      ..loadingStyle = .custom
      ..indicatorType = .ring
      ..maskType = .clear
      ..contentPadding = const .all(16)
      ..textColor = Colors.white
      ..textPadding = .zero
      ..textStyle = theme.textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.1)
      ..userInteractions = false
      ..dismissOnTap = false
      ..indicatorSize = 20.0
      ..lineWidth = 2.0
      ..radius = theme.uiTheme.size.corner.regular;
  } */

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.settingsOf(context);

    final theme = settings.theme;
    final darkTheme = theme.buildThemeData(Brightness.dark);
    final lightTheme = theme.buildThemeData(Brightness.light);

    return MaterialApp(
      restorationScopeId: 'flutter_template_name',
      debugShowCheckedModeBanner: !Config.environment.isProduction,
      onGenerateTitle: (context) => Localization.of(context).title,

      // Localizations
      supportedLocales: /* Locales.values */ Localization.supportedLocales,
      localizationsDelegates: App.localizationsDelegates,
      locale: settings.locale,

      // Theme
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: theme.themeMode,

      // Scopes
      home: Scopes(navigator: _navigator),
      builder: EasyLoading.init(
        builder: (context, child) {
          assert(debugCheckHasMediaQuery(context)); // ignore: prefer_asserts_with_message
          return MediaQuery(
            key: _builderKey,
            data: MediaQuery.of(context).copyWith(
              boldText: false,
              textScaler: .noScaling,
              // textScaler: TextScaler.linear(mediaQueryData.textScaler.scale(settings.textScale).clamp(0.5, 2)),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

/// {@template app_error}
/// Used to display error screen when app fails to initialize.
/// {@endtemplate}
class App$Error extends StatelessWidget {
  /// {@macro app_error}
  const App$Error({this.error, this.stackTrace, super.key});

  /// Error
  final Object? error;

  /// StackTrace
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final theme = View.of(context).platformDispatcher.platformBrightness == Brightness.dark
        ? UIThemeData.dark()
        : UIThemeData.light();
    return MaterialApp(
      title: 'App Error',
      theme: theme,
      /* supportedLocales: Locales.values, */
      localizationsDelegates: App.localizationsDelegates,
      home: _App$Error$HomeScreen(error: error, stackTrace: stackTrace),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: BugReportScope(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

// TODO(ziqq): Add localization.
// Anton Ustinoff <a.a.ustinoff@gmail.com>, 05 February 2026
/// Error Home Screen widget.
/// {@macro app_error}
class _App$Error$HomeScreen extends StatelessWidget {
  /// {@macro app_error}
  const _App$Error$HomeScreen({
    required this.error,
    required this.stackTrace,
    super.key, // ignore: unused_element_parameter
  });

  final Object? error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final isDark = View.of(context).platformDispatcher.platformBrightness == Brightness.dark;
    final theme = isDark ? UIThemeData.dark() : UIThemeData.light();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CommonErrorWidget$Icon(error),
                SizedBox(height: theme.uiTheme.padding),

                // --- Title --- //
                CommonErrorWidget$Title(error, text: 'Что-то пошло не так, но всё под контролем!'),
                SizedBox(height: theme.uiTheme.padding / 2),

                // --- Description --- //
                CommonErrorWidget$Subtitle(
                  error,
                  text:
                      'Попробуйте перезапустить приложение. Если ошибка снова появится — напишите нам прикрепив скриншот экрана или нажмите кнопку ниже "{context.stringOf().actionShareTheError}". Мы обязательно поможем!',
                ),
                SizedBox(height: theme.uiTheme.padding / 2),
                const Spacer(),

                // --- Buttons --- //
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    Localization.of(context).contactSupportButton,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.uiTheme.color.accent),
                  ),
                  onPressed: () {} /* () => showDialog$FollowAnExternalLink(
                    context,
                    messenger: MessengerType.whatsapp.alias,
                    successActionText: context.stringOf().actionGoTo(MessengerType.whatsapp.alias),
                    onSucceeded: () => PhoneUtil.openWhatsapp(
                      Config.feedbackPhone,
                      text:
                          'Здравствуйте! У меня возникла ошибка в приложении. Можете помочь?\n\nОшибка: ${ErrorUtil.formatMessage(error)}',
                      onError: (error, stackTrace) {
                        showDialog$Messenger$NotInstalled(context, MessengerType.whatsapp);
                        ErrorUtil.logError(error, stackTrace).ignore();
                      },
                    ).ignore(),
                  ) */,
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    Localization.of(context).shareErrorButton,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.uiTheme.color.accent),
                  ),
                  onPressed: () {
                    final message = BugReportUtil.generateErrorMessage(
                      route: 'AppErrorRoute',
                      error: error,
                      stackTrace: stackTrace,
                      user: const User.unauthenticated(),
                    );
                    BugReportUtil.instance
                        .sendToTelegramAsFile(
                          metadata: context.ext.dependencies.metadata,
                          user: const User.unauthenticated(),
                          message: message,
                          onSuccess: () => UI
                              .showSnackBar(
                                context: context,
                                useHapticFeedback: false,
                                type: UISnackBarType.success,
                                message: Localization.of(context).shareErrorSuccessMessage,
                              )
                              .ignore(),
                        )
                        .ignore();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
