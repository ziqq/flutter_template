import 'package:flutter/foundation.dart' show Diagnosticable, DiagnosticPropertiesBuilder, FlagProperty;
import 'package:meta/meta.dart';

/// {@template user_preferences}
/// User preferences
/// {@endtemplate}
@immutable
final class UserPreferences with Diagnosticable {
  /// {@macro user_preferences}
  const UserPreferences({
    this.useBeta = false,
    this.useDebug = false,
    this.useDevelopment = false,
    this.useExpiremental = false,
    this.useHapticFeedback = true,
  });

  /// Create an default [UserPreferences] instance.
  @literal
  const factory UserPreferences.empty() = UserPreferences;

  /// The aportunity to use beta app version.
  final bool useBeta;

  /// The aportunity to use debug mode.
  final bool useDebug;

  /// The aportunity to use development mode.
  final bool useDevelopment;

  /// The aportunity to use experimental app functions.
  final bool useExpiremental;

  /// Oportunity to use haptic feedback.
  final bool useHapticFeedback;

  /// Copy the [UserPreferences] with new values.
  UserPreferences copyWith({
    bool? useBeta,
    bool? useDebug,
    bool? useDevelopment,
    bool? useExpiremental,
    bool? useHapticFeedback,
  }) => UserPreferences(
    useBeta: useBeta ?? this.useBeta,
    useDebug: useDebug ?? this.useDebug,
    useDevelopment: useDevelopment ?? this.useDevelopment,
    useExpiremental: useExpiremental ?? this.useExpiremental,
    useHapticFeedback: useHapticFeedback ?? this.useHapticFeedback,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.useBeta == useBeta &&
        other.useDebug == useDebug &&
        other.useDevelopment == useDevelopment &&
        other.useExpiremental == useExpiremental &&
        other.useHapticFeedback == useHapticFeedback;
  }

  @override
  int get hashCode => Object.hash(useBeta, useDebug, useDevelopment, useExpiremental, useHapticFeedback);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(FlagProperty('useBeta', value: useBeta))
      ..add(FlagProperty('useDebug', value: useDebug))
      ..add(FlagProperty('useDevelopment', value: useDevelopment))
      ..add(FlagProperty('useExpiremental', value: useExpiremental))
      ..add(FlagProperty('useHapticFeedback', value: useHapticFeedback));
    super.debugFillProperties(properties);
  }
}
