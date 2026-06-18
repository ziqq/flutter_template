import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/controller/app_controller.dart';
import 'package:flutter_template_name/src/common/model/option.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:flutter_template_name/src/feature/settings/data/settings_repository.dart';
import 'package:flutter_template_name/src/feature/settings/model/app_settings.dart';
import 'package:flutter_template_name/src/feature/settings/model/user_preferences.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';

/// {@template settings_state}
/// SettingsState is a base class
/// for managing the state of the settings app settings.
/// {@endtemplate}
sealed class SettingsState extends _$SettingsStateBase {
  /// {@macro settings_state}
  const SettingsState({required super.preferences, required super.settings, required super.message});

  /// Idling state
  /// {@macro settings_state}
  const factory SettingsState.idle({
    required UserPreferences preferences,
    required AppSettings settings,
    String message,
  }) = SettingsState$Idle;

  /// Failed state
  /// {@macro settings_state}
  const factory SettingsState.failed({
    required UserPreferences preferences,
    required AppSettings settings,
    String message,
  }) = SettingsState$Failed;

  /// Processing
  /// {@macro settings_state}
  const factory SettingsState.processing({
    required UserPreferences preferences,
    required AppSettings settings,
    String message,
  }) = SettingsState$Processing;
}

/// Idling state
/// {@macro settings_state}
final class SettingsState$Failed extends SettingsState {
  /// {@macro settings_state}
  const SettingsState$Failed({required super.preferences, required super.settings, super.message = 'Failed'});

  @override
  String get type => 'failed';
}

/// Idling state
/// {@macro settings_state}
final class SettingsState$Idle extends SettingsState {
  /// {@macro settings_state}
  const SettingsState$Idle({required super.preferences, required super.settings, super.message = 'Idle'});

  @override
  String get type => 'idle';
}

/// Processing
/// {@macro settings_state}
final class SettingsState$Processing extends SettingsState {
  /// {@macro settings_state}
  const SettingsState$Processing({required super.preferences, required super.settings, super.message = 'Processing'});

  @override
  String get type => 'processing';
}

/// Pattern matching for [SettingsState].
typedef _SettingsStateMatch<R, S extends SettingsState> = R Function(S state);

/// Base class for [SettingsState] to provide common properties and methods.
/// {@macro settings_state}
@immutable
abstract base class _$SettingsStateBase {
  /// {@macro settings_state}
  const _$SettingsStateBase({required this.preferences, required this.settings, required this.message});

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

  /// Check if is Idle.
  bool get isIdle => this is SettingsState$Idle;

  /// Check if is Processing.
  bool get isProcessing => this is SettingsState$Processing;

  /// Check if is Failed.
  bool get isFailed => this is SettingsState$Failed;

  /// Pattern matching for [SettingsState].
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

  /// Pattern matching for [SettingsState].
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

  /// Pattern matching for [SettingsState].
  R? mapOrNull<R>({
    _SettingsStateMatch<R, SettingsState$Processing>? processing,
    _SettingsStateMatch<R, SettingsState$Failed>? failed,
    _SettingsStateMatch<R, SettingsState$Idle>? idle,
  }) => map<R?>(processing: processing ?? (_) => null, failed: failed ?? (_) => null, idle: idle ?? (_) => null);

  @override
  int get hashCode => Object.hashAll([preferences, settings, message, type]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _$SettingsStateBase &&
        other.preferences == preferences &&
        other.settings == settings &&
        other.message == message &&
        other.type == type;
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
    required ISettingsRepository repository,
    super.initialState = const SettingsState.idle(preferences: UserPreferences.empty(), settings: AppSettings.empty()),
  }) : _repository = repository,
       super(name: 'SettingsController');

  /// The repository to fetch settings data.
  final ISettingsRepository _repository;

  /// Restore settings from cache.
  Future<void> restore() => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Restoring settings',
        ),
      );
      l.i('Restore settings from cache...');
      final settings = await _repository.readSettings();
      l.i('Restore user preferences from cache...');
      final preferences = await _repository.readPreferences();
      setState(SettingsState.processing(preferences: preferences, settings: settings, message: 'Settings restored'));
    },
    error: (e, s) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        message: 'Failed to restore settings: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'restore',
  );

  /// Change theme mode.
  Future<void> setThemeMode(ThemeMode themeMode) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting theme mode to: $themeMode',
        ),
      );
      l.i('Seting theme mode...');
      final newSettings = state.settings.copyWith(theme: state.settings.theme.copyWith(themeMode: themeMode));
      await _repository.saveSettings(newSettings);
      setState(
        SettingsState.processing(preferences: state.preferences, settings: newSettings, message: 'Theme mode changed'),
      );
    },
    error: (e, _) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        message: 'Failed to set theme mode: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setThemeMode',
    meta: <String, Object?>{'theme_mode': themeMode.toString()},
  );

  /// Change locale.
  Future<void> setLocale(Locale locale) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting locale to: $locale',
        ),
      );
      l.i('Seting locale...');
      final newSettings = state.settings.copyWith(locale: locale);
      await _repository.saveSettings(newSettings);
      setState(
        SettingsState.processing(preferences: state.preferences, settings: newSettings, message: 'Locale changed'),
      );
    },
    error: (e, _) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        message: 'Failed to set locale: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setLocale',
    meta: <String, Object?>{'locale': locale.toString()},
  );

  /// Change accent color.
  Future<void> setAccentColor(Color? color) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting accent color to: ${color == null ? 'null' : color.toString()}',
        ),
      );
      l.i('Seting accent color...');
      final newSettings = state.settings.copyWith(theme: state.settings.theme.copyWith(accent: Option<Color?>(color)));
      await _repository.saveSettings(newSettings);
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: newSettings,
          message: 'Accent color changed',
        ),
      );
    },
    error: (e, _) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        message: 'Failed to set accent color: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setAccentColor',
    meta: <String, Object?>{'accent_color': color?.toString()},
  );

  /// Change use beta version.
  Future<void> setUseBeta(bool useBeta) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting useBeta to: $useBeta',
        ),
      );
      l.i('Seting use beta...');
      final newPreferences = state.preferences.copyWith(useBeta: useBeta);
      await _repository.savePreferences(newPreferences);
      setState(
        SettingsState.processing(preferences: newPreferences, settings: state.settings, message: 'Use beta changed'),
      );
    },
    error: (e, _) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        message: 'Failed to set use beta: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseBeta',
    meta: <String, Object?>{'use_beta': useBeta.toString()},
  );

  /// Change use debug.
  Future<void> setUseDebug(bool useDebug) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting useDebug: $useDebug',
        ),
      );
      l.i('Seting use debug...');
      final newPreferences = state.preferences.copyWith(useDebug: useDebug);
      await _repository.savePreferences(newPreferences);
      setState(
        SettingsState.processing(preferences: newPreferences, settings: state.settings, message: 'Use debug changed'),
      );
    },
    error: (e, _) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        message: 'Failed to set use debug: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseDebug',
    meta: <String, Object?>{'use_debug': useDebug.toString()},
  );

  /// Change use development mode.
  Future<void> setUseDevelompent(bool useDevelopment) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting useDevelopment: $useDevelopment',
        ),
      );
      l.i('Seting use development...');
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
    error: (e, _) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        message: 'Failed to set use development: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseDevelopment',
    meta: <String, Object?>{'use_development': useDevelopment.toString()},
  );

  /// Change use expiremental app functions.
  Future<void> setUseExpiremental(bool useExpiremental) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting useExpiremental: $useExpiremental',
        ),
      );
      l.i('Seting use expiremental...');
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
    error: (e, _) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        message: 'Failed to set use expiremental: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseExpiremental',
    meta: <String, Object?>{'use_expiremental': useExpiremental.toString()},
  );

  /// Change use haptic feedback.
  Future<void> setUseHapticFeedback(bool useHapticFeedback) => handle(
    () async {
      setState(
        SettingsState.processing(
          preferences: state.preferences,
          settings: state.settings,
          message: 'Seting use [HapticFeedback] to: $useHapticFeedback',
        ),
      );
      l.i('Seting use [HapticFeedback]...');
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
    error: (e, _) async => setState(
      SettingsState.failed(
        preferences: state.preferences,
        settings: state.settings,
        message: 'Failed to set use [HapticFeedback]: ${ErrorUtil.formatMessage(e)}',
      ),
    ),
    done: () async => setState(SettingsState.idle(preferences: state.preferences, settings: state.settings)),
    name: 'setUseHapticFeedback',
    meta: <String, Object?>{'use_haptic_feedback': useHapticFeedback.toString()},
  );
}
