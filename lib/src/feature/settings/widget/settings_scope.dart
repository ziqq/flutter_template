import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_theme.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';
import 'package:ui/ui.dart';

/// The aspect of the [SettingsScope].
enum SettingsAspect {
  /// No changes.
  none,

  /// Locale has changed.
  locale,

  /// App settings has changed.
  settings,

  /// Settings state has changed.
  state,

  /// Theme has changed.
  theme,

  /// Theme mode has changed.
  themeMode,

  /// User preferences has changed.
  userPreferences,
}

/// {@template settings_scope}
/// Settings scope is responsible for handling settings-related stuff.
/// {@endtemplate}
class SettingsScope extends StatefulWidget {
  /// {@macro settings_scope}
  const SettingsScope({required this.child, super.key});

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Get the [SettingsController] of the closest [SettingsScope] ancestor.
  static SettingsController of(BuildContext context) =>
      _InheritedSettings.of(context, aspect: SettingsAspect.none).scope._controller;

  /// Get a specific aspect of the closest [SettingsScope] ancestor.
  static Object? aspectOf(BuildContext context, SettingsAspect aspect, {bool listen = true}) => switch (aspect) {
    SettingsAspect.locale => localeOf(context, listen: listen),
    SettingsAspect.settings => settingsOf(context, listen: listen),
    SettingsAspect.state => stateOf(context, listen: listen),
    SettingsAspect.theme => themeOf(context, listen: listen),
    SettingsAspect.themeMode => themeModeOf(context, listen: listen),
    SettingsAspect.userPreferences => userPreferencesOf(context, listen: listen),
    SettingsAspect.none => null,
  };

  /// Get the current app [Locale]
  static Locale localeOf(BuildContext context, {bool listen = true}) =>
      _InheritedSettings.of(context, aspect: listen ? SettingsAspect.locale : SettingsAspect.none).settings.locale;

  /// Get the current [SettingsState]
  static SettingsState stateOf(BuildContext context, {bool listen = true}) =>
      _InheritedSettings.of(context, aspect: listen ? SettingsAspect.state : SettingsAspect.none).state;

  /// Get [AppSettings] of the closest [SettingsScope] ancestor.
  static AppSettings settingsOf(BuildContext context, {bool listen = true}) =>
      _InheritedSettings.of(context, aspect: listen ? SettingsAspect.settings : SettingsAspect.none).settings;

  /// Get the [AppTheme] of the closest [SettingsScope] ancestor.
  static AppTheme themeOf(BuildContext context, {bool listen = true}) =>
      _InheritedSettings.of(context, aspect: listen ? SettingsAspect.theme : SettingsAspect.none).settings.theme;

  /// Get the [ThemeMode] of the closest [SettingsScope] ancestor.
  static ThemeMode themeModeOf(BuildContext context, {bool listen = true}) => _InheritedSettings.of(
    context,
    aspect: listen ? SettingsAspect.themeMode : SettingsAspect.none,
  ).settings.theme.themeMode;

  /// Set the theme mode of the closest [SettingsScope] ancestor.
  static Future<void> setThemeMode(BuildContext context, ThemeMode themeMode) => of(context).setThemeMode(themeMode);

  /// Get the [UserPreferences] of the closest [SettingsScope] ancestor.
  static UserPreferences userPreferencesOf(BuildContext context, {bool listen = true}) => _InheritedSettings.of(
    context,
    aspect: listen ? SettingsAspect.userPreferences : SettingsAspect.none,
  ).userPreferences;

  @override
  State<SettingsScope> createState() => _SettingsScopeState();
}

/// State for widget SettingsScope
class _SettingsScopeState extends State<SettingsScope> {
  late final SettingsController _controller;
  late SettingsState _state;

  @override
  void initState() {
    super.initState();
    _controller = Dependencies.of(context).settingsController;
    _controller.addListener(_onStateChanged);
    _state = _controller.state;
  }

  /* @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final b = View.maybeOf(context)?.platformDispatcher.platformBrightness;
    final isDark = b == Brightness.dark;
    if (b != _theme.brightness) {
      _theme = _$buildTheme(
        isDark ? UIThemeData.dark() : UIThemeData.light(),
        _uiTheme,
      );
    }
  } */

  @override
  void dispose() {
    _controller
      ..removeListener(_onStateChanged)
      ..dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    if (_controller.state.isProcessing) return;

    final newState = _controller.state;
    final prevState = _state;

    if (identical(newState, prevState)) return;

    _state = newState;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _InheritedSettings(scope: this, state: _state, child: widget.child);
}

/// Inherited widget for quick access in the element tree.
class _InheritedSettings extends InheritedModel<SettingsAspect> {
  const _InheritedSettings({required this.scope, required this.state, required super.child});

  /// This settings scope state.
  /// This is the state of the settings scope.
  final _SettingsScopeState scope;

  /// The settings state from the controller.
  /// This is the state of the settings controller [SettingsController].
  final SettingsState state;

  /// App settings.
  /// This is the cached settings from the state.
  AppSettings get settings => state.settings;

  /// App locale.
  /// This is the cached locale from the state.
  Locale get locale => settings.locale;

  /// App theme.
  /// This is the cached theme from the state.
  AppTheme get theme => settings.theme;

  /// Theme mode.
  /// This is the cached theme mode from the state.
  ThemeMode get themeMode => theme.themeMode;

  /// User preferences.
  /// This is the cached user preferences from the state.
  UserPreferences get userPreferences => state.preferences;

  static _InheritedSettings? maybeOf(BuildContext context, {SettingsAspect aspect = SettingsAspect.none}) =>
      switch (aspect) {
        // Do not notify about changes.
        SettingsAspect.none => context.getInheritedWidgetOfExactType<_InheritedSettings>(),

        // Notify about every change.
        SettingsAspect.state => context.dependOnInheritedWidgetOfExactType<_InheritedSettings>(),

        // Notify about changes in app locale.
        SettingsAspect.locale => InheritedModel.inheritFrom<_InheritedSettings>(context, aspect: SettingsAspect.locale),

        // Notify about changes in app settings.
        SettingsAspect.settings => InheritedModel.inheritFrom<_InheritedSettings>(
          context,
          aspect: SettingsAspect.settings,
        ),

        // Notify about changes in app theme.
        SettingsAspect.theme => InheritedModel.inheritFrom<_InheritedSettings>(context, aspect: SettingsAspect.theme),

        // Notify about changes in app theme mode.
        SettingsAspect.themeMode => InheritedModel.inheritFrom<_InheritedSettings>(
          context,
          aspect: SettingsAspect.themeMode,
        ),

        // Notify about changes in user preferences.
        SettingsAspect.userPreferences => InheritedModel.inheritFrom<_InheritedSettings>(
          context,
          aspect: SettingsAspect.userPreferences,
        ),
      };

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a _InheritedSettings of the exact type',
    'out_of_scope',
  );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `SettingsScope.of(context)`.
  static _InheritedSettings of(BuildContext context, {SettingsAspect aspect = SettingsAspect.none}) =>
      maybeOf(context, aspect: aspect) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant _InheritedSettings oldWidget) =>
      !identical(oldWidget.settings, settings) || !identical(oldWidget.userPreferences, userPreferences);

  @override
  bool updateShouldNotifyDependent(_InheritedSettings oldWidget, Set<Object> dependencies) {
    for (final d in dependencies) {
      switch (d) {
        case SettingsAspect.locale when oldWidget.locale != locale:
          // Notify about changes in app locale.
          return true;
        case SettingsAspect.settings when !identical(oldWidget.settings, settings):
          // Notify about changes in app settings.
          return true;
        case SettingsAspect.theme when !identical(oldWidget.theme, theme):
          // Notify about changes in app theme.
          return true;
        case SettingsAspect.themeMode when oldWidget.themeMode != themeMode:
          // Notify about changes in app theme mode.
          return true;
        case SettingsAspect.userPreferences when !identical(oldWidget.userPreferences, userPreferences):
          // Notify about changes in user preferences.
          return true;
        default:
          continue;
      }
    }
    return false;
  }
}
