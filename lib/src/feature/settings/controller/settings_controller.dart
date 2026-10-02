/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 05 January 2024
 */

import 'package:flutter_template_name/src/common/model/option.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:flutter_template_name/src/common/controller/app_controller.dart';
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:flutter_template_name/src/feature/settings/data/settings_repository.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';

/// {@template settings_state}
/// SettingsState is a base class
/// for managing the state of the settings app settings.
/// {@endtemplate}
sealed class SettingsState extends _$SettingsStateBase {
  /// {@macro settings_state}
  const SettingsState({
    required super.preferences,
    required super.settings,
    required super.message,
    super.error,
    super.stackTrace,
  });

  /// Creates an idle state — no operation is in progress.
  /// {@macro settings_state}
  const factory SettingsState.idle({
    required UserPreferences preferences,
    required AppSettings settings,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = SettingsState$Idle;

  /// Creates a failed state — the last operation threw an error.
  /// {@macro settings_state}
  const factory SettingsState.failed({
    required UserPreferences preferences,
    required AppSettings settings,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = SettingsState$Failed;

  /// Creates a processing state — an operation is currently running.
  /// {@macro settings_state}
  const factory SettingsState.processing({
    required UserPreferences preferences,
    required AppSettings settings,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = SettingsState$Processing;
}

/// Failed state: the last settings/preferences operation ended with an error.
///
/// [error] and [stackTrace] describe the failure.
/// {@macro settings_state}
final class SettingsState$Failed extends SettingsState {
  /// {@macro settings_state}
  const SettingsState$Failed({
    required super.preferences,
    required super.settings,
    super.message = 'Failed',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'failed';
}

/// Idle state: nothing is in progress and the settings are ready to use.
/// {@macro settings_state}
final class SettingsState$Idle extends SettingsState {
  /// {@macro settings_state}
  const SettingsState$Idle({
    required super.preferences,
    required super.settings,
    super.message = 'Idle',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'idle';
}

/// Processing state: a settings/preferences operation is currently running.
/// {@macro settings_state}
final class SettingsState$Processing extends SettingsState {
  /// {@macro settings_state}
  const SettingsState$Processing({
    required super.preferences,
    required super.settings,
    super.message = 'Processing',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'processing';
}

/// Signature of a callback that maps a concrete [SettingsState] subtype [S]
/// to a result of type [R]; used by [SettingsState] pattern-matching helpers.
typedef _SettingsStateMatch<R, S extends SettingsState> = R Function(S state);

/// Base class for [SettingsState] to provide common properties and methods.
/// {@macro settings_state}
@immutable
abstract base class _$SettingsStateBase {
  /// {@macro settings_state}
  const _$SettingsStateBase({
    required this.preferences,
    required this.settings,
    required this.message,
    this.error,
    this.stackTrace,
  });

  /// The current state type.
  abstract final String type;

  /// The current app settings.
  @nonVirtual
  final AppSettings settings;

  /// The current user preferences.
  @nonVirtual
  final UserPreferences preferences;

  /// Message or state description.
  @nonVirtual
  final String message;

  /// The error object, if any.
  @nonVirtual
  final Object? error;

  /// Stack trace of the error, if any.
  @nonVirtual
  final StackTrace? stackTrace;

  /// Whether the controller is idle.
  bool get isIdle => this is SettingsState$Idle;

  /// Whether the last operation failed.
  bool get isFailed => this is SettingsState$Failed;

  /// Whether this state is [SettingsState$Processing].
  bool get isProcessing => this is SettingsState$Processing;

  /// Exhaustively map this state to [R] by providing a callback for every
  /// [SettingsState] variant.
  R map<R>({
    required _SettingsStateMatch<R, SettingsState$Processing> processing,
    required _SettingsStateMatch<R, SettingsState$Failed> failed,
    required _SettingsStateMatch<R, SettingsState$Idle> idle,
  }) => switch (this) {
    SettingsState$Processing s => processing(s),
    SettingsState$Failed s => failed(s),
    SettingsState$Idle s => idle(s),
    _ => throw AssertionError(), // coverage:ignore-line
  };

  /// Map this state to [R], falling back to [orElse] for any variant whose
  /// callback is omitted.
  R maybeMap<R>({
    required R Function() orElse,
    _SettingsStateMatch<R, SettingsState$Processing>? processing,
    _SettingsStateMatch<R, SettingsState$Failed>? failed,
    _SettingsStateMatch<R, SettingsState$Idle>? idle,
  }) => map<R>(
    processing: processing ?? (_) => orElse(),
    failed: failed ?? (_) => orElse(),
    idle: idle ?? (_) => orElse(),
  );

  /// Map this state to [R], returning `null` for any variant whose callback
  /// is omitted.
  R? mapOrNull<R>({
    _SettingsStateMatch<R, SettingsState$Processing>? processing,
    _SettingsStateMatch<R, SettingsState$Failed>? failed,
    _SettingsStateMatch<R, SettingsState$Idle>? idle,
  }) => map<R?>(processing: processing ?? (_) => null, failed: failed ?? (_) => null, idle: idle ?? (_) => null);

  @override
  int get hashCode => Object.hash(preferences, settings, message, type, error, stackTrace);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _$SettingsStateBase &&
        other.preferences == preferences &&
        other.settings == settings &&
        other.type == type &&
        other.message == message &&
        other.error == error &&
        other.stackTrace == stackTrace;
  }

  @override
  String toString() => 'SettingsState.$type{message: $message}';
}

/// {@template settings_controller}
/// A controller that holds and operates the app settings.
/// {@endtemplate}
final class SettingsController extends AppController$Sequential<SettingsState> {
  /// {@macro settings_controller}
  SettingsController({
    required this._repository,
    super.initialState = const SettingsState.idle(
      preferences: UserPreferences.empty(),
      settings: AppSettings.empty(),
      message: 'Initial',
    ),
  }) : super(name: 'SettingsController');

  /// The repository to fetch settings data.
  final ISettingsRepository _repository;

  /// Restore [AppSettings] and [UserPreferences] from the local cache.
  ///
  /// Emits [SettingsState$Processing] while reading, then [SettingsState$Idle]
  /// on success or [SettingsState$Failed] if the repository throws.
  ///
  /// [appmetadata] — optional metadata attached to the operation for logging.
  Future<void> restore({Object? appmetadata}) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Restoring settings' /* 'Restoring settings & remote config' */,
        ),
      );

      final settings = await _repository.readSettings();

      final preferences = await _repository.readPreferences();
      setState(SettingsState.processing(preferences: preferences, settings: settings, message: 'Settings restored'));
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to restore settings: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(
      SettingsState.idle(
        preferences: state.preferences,
        settings: state.settings,
        error: state.error,
        stackTrace: state.stackTrace,
      ),
    ),
    name: 'restore',
    meta: <String, Object?>{'app_metadata': appmetadata},
  );

  /// Change the app [ThemeMode] (system/light/dark).
  ///
  /// Persists the updated [AppSettings] and logs a `theme_mode_changed`
  /// analytics event. Emits processing → idle, or failed on error.
  ///
  /// [themeMode] — the theme mode to apply.
  Future<void> setThemeMode(ThemeMode themeMode) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting theme mode to: $themeMode',
        ),
      );

      final newSettings = state.settings.copyWith(theme: state.settings.theme.copyWith(themeMode: themeMode));
      await _repository.saveSettings(settings: newSettings);
      setState(
        SettingsState.processing(preferences: state.preferences, settings: newSettings, message: 'Theme mode changed'),
      );
      Analytics.instance
          .logEvent(
            'settings',
            'theme_mode_changed',
            parameters: {
              'theme_mode': switch (themeMode) {
                .system => 'system',
                .light => 'light',
                .dark => 'dark',
              },
            },
          )
          .ignore();
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to set theme mode: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setThemeMode',
    meta: <String, Object?>{'theme_mode': themeMode.toString()},
  );

  /// Change the app [Locale].
  ///
  /// Persists the updated [AppSettings] and logs a `locale_changed` analytics
  /// event. Emits processing → idle, or failed on error.
  ///
  /// [locale] — the locale to apply.
  Future<void> setLocale(Locale locale) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting locale (old: ${state.settings.locale}, new: $locale)',
        ),
      );

      final newSettings = state.settings.copyWith(locale: locale);
      await _repository.saveSettings(settings: newSettings);
      setState(
        SettingsState.processing(preferences: state.preferences, settings: newSettings, message: 'Locale changed'),
      );
      Analytics.instance.logEvent('settings', 'locale_changed', parameters: {'locale': locale.languageCode}).ignore();
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to set locale: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setLocale',
    meta: <String, Object?>{'locale': locale.toString()},
  );

  /// Change the theme accent [color], or reset it to the default when `null`.
  ///
  /// Persists the updated [AppSettings] and logs a `settings_accent_color_changed`
  /// analytics event. Emits processing → idle, or failed on error.
  ///
  /// [color] — the accent color to apply, or `null` to use the default.
  /// [onProcessing] — called when saving starts.
  /// [onSucceeded] — called after the color is saved successfully.
  /// [onError] — called with the error if persistence fails.
  /// [onDone] — called once the operation completes (success or failure).
  Future<void> setAccentColor(
    Color? color, {
    void Function()? onDone,
    void Function()? onSucceeded,
    void Function()? onProcessing,
    void Function(Object error)? onError,
  }) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Setting accent color to: ${color == null ? 'Default' : color.toString()}',
        ),
      );
      onProcessing?.call();

      final newSettings = state.settings.copyWith(theme: state.settings.theme.copyWith(accent: Option<Color?>(color)));
      await _repository.saveSettings(settings: newSettings);
      setState(
        SettingsState.processing(
          settings: newSettings,
          preferences: state.preferences,
          message: 'Accent color changed',
        ),
      );
      Analytics.instance
          .logEvent('settings', 'accent_color_changed', parameters: {'has_custom_color': (color != null).toString()})
          .ignore();
      onSucceeded?.call();
    },
    error: (e, s) async {
      setState(
        SettingsState.failed(
          preferences: state.preferences,
          settings: state.settings,
          error: e,
          stackTrace: s,
          message: 'Failed to set accent color: ${ErrorUtil.formatMessage(e)}',
        ),
      );
      onError?.call(e);
    },
    done: () async {
      setState(SettingsState.idle(preferences: state.preferences, settings: state.settings));
      onDone?.call();
    },
    name: 'setAccentColor',
    meta: <String, Object?>{'accent_color': color?.toString()},
  );

  /// Persists the device-level product analytics sending override.
  Future<void> setAnalyticsDataSendingEnabled(bool enabled) => handle(
    () async {
      setState(SettingsState.processing(preferences: state.preferences, settings: state.settings));
      final preferences = state.preferences.copyWith(analyticsDataSendingEnabled: enabled);
      await _repository.savePreferences(preferences);
      setState(SettingsState.processing(preferences: preferences, settings: state.settings));
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to save analytics data sending preference: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setAnalyticsDataSendingEnabled',
  );

  /// Toggle the beta app version preference.
  ///
  /// Persists [UserPreferences.useBeta] via the repository. Emits
  /// processing → idle, or failed on error.
  ///
  /// [useBeta] — `true` enables the beta version, `false` disables it.
  Future<void> setUseBeta(bool useBeta) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting useBeta to: $useBeta',
        ),
      );

      final newPreferences = state.preferences.copyWith(useBeta: useBeta);
      await _repository.savePreferences(newPreferences);
      setState(
        SettingsState.processing(preferences: newPreferences, settings: state.settings, message: 'Use beta changed'),
      );
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to set use beta: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseBeta',
    meta: <String, Object?>{'use_beta': useBeta.toString()},
  );

  /// Toggle the debug mode preference.
  ///
  /// Persists [UserPreferences.useDebug] via the repository. Emits
  /// processing → idle, or failed on error.
  ///
  /// [useDebug] — `true` enables debug mode, `false` disables it.
  Future<void> setUseDebug(bool useDebug) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting useDebug: $useDebug',
        ),
      );

      final newPreferences = state.preferences.copyWith(useDebug: useDebug);
      await _repository.savePreferences(newPreferences);
      setState(
        SettingsState.processing(preferences: newPreferences, settings: state.settings, message: 'Use debug changed'),
      );
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to set use debug: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseDebug',
    meta: <String, Object?>{'use_debug': useDebug.toString()},
  );

  /// Toggle the development mode preference.
  ///
  /// Persists [UserPreferences.useDevelopment] via the repository. Emits
  /// processing → idle, or failed on error.
  ///
  /// [useDevelopment] — `true` enables development mode, `false` disables it.
  Future<void> setUseDevelompent(bool useDevelopment) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting useDevelopment: $useDevelopment',
        ),
      );

      final newPreferences = state.preferences.copyWith(useDevelopment: useDevelopment);
      await _repository.savePreferences(newPreferences);
      setState(
        SettingsState.processing(
          preferences: newPreferences,
          settings: state.settings,
          message: 'Use development changed',
        ),
      );
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to set use development: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseDevelopment',
    meta: <String, Object?>{'use_development': useDevelopment.toString()},
  );

  /// Toggle the experimental app functions preference.
  ///
  /// Persists [UserPreferences.useExpiremental] via the repository. Emits
  /// processing → idle, or failed on error.
  ///
  /// [useExpiremental] — `true` enables experimental functions, `false` disables them.
  Future<void> setUseExpiremental(bool useExpiremental) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting useExpiremental: $useExpiremental',
        ),
      );

      final newPreferences = state.preferences.copyWith(useExpiremental: useExpiremental);
      await _repository.savePreferences(newPreferences);
      setState(
        SettingsState.processing(
          preferences: newPreferences,
          settings: state.settings,
          message: 'Use expiremental changed',
        ),
      );
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to set use expiremental: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseExpiremental',
    meta: <String, Object?>{'use_expiremental': useExpiremental.toString()},
  );

  /// Toggle the haptic feedback preference.
  ///
  /// Persists [UserPreferences.useHapticFeedback] via the repository. Emits
  /// processing → idle, or failed on error.
  ///
  /// [useHapticFeedback] — `true` enables haptic feedback, `false` disables it.
  Future<void> setUseHapticFeedback(bool useHapticFeedback) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting use [HapticFeedback] to: $useHapticFeedback',
        ),
      );

      final newPreferences = state.preferences.copyWith(useHapticFeedback: useHapticFeedback);
      await _repository.savePreferences(newPreferences);
      setState(
        SettingsState.processing(
          preferences: newPreferences,
          settings: state.settings,
          message: 'Use [HapticFeedback] changed',
        ),
      );
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to set use [HapticFeedback]: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseHapticFeedback',
    meta: <String, Object?>{'use_haptic_feedback': useHapticFeedback.toString()},
  );

  /// Toggle the iOS 26+ liquid (glass) theme.
  ///
  /// Persists [UserPreferences.useIOS26LiquidTheme] via the repository and
  /// republishes the updated [SettingsState].
  ///
  /// Emits [SettingsState$Processing] while saving, then [SettingsState$Idle]
  /// on success or [SettingsState$Failed] if persistence throws.
  ///
  /// [useIOS26LiquidTheme] — `true` enables the liquid theme, `false` disables it.
  Future<void> setUseIOS26LiquidTheme(bool useIOS26LiquidTheme) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting useIOS26LiquidTheme: $useIOS26LiquidTheme',
        ),
      );

      final newPreferences = state.preferences.copyWith(useIOS26LiquidTheme: useIOS26LiquidTheme);
      await _repository.savePreferences(newPreferences);
      setState(
        SettingsState.processing(
          preferences: newPreferences,
          settings: state.settings,
          message: 'Use iOS 26+ liquid theme changed',
        ),
      );
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        error: e,
        stackTrace: s,
        message: 'Failed to set use iOS 26+ liquid theme: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseIOS26LiquidTheme',
    meta: <String, Object?>{'use_ios26_liquid_theme': useIOS26LiquidTheme.toString()},
  );
}
