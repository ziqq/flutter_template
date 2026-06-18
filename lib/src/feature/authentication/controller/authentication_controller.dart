import 'dart:async';

import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:flutter_template_name/src/feature/authentication/data/authentication_repository.dart';
import 'package:flutter_template_name/src/feature/authentication/model/sign_in_data.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:l/l.dart';

/// {@macro authentication_state}
///
/// Pattern matching for [AuthenticationState].
typedef _AuthenticationStateMatch<R, S extends AuthenticationState> = R Function(S state);

/// {@template authentication_state}
/// AuthenticationState.
/// {@endtemplate}
sealed class AuthenticationState extends _$AuthenticationStateBase {
  /// {@macro authentication_state}
  const AuthenticationState({
    required super.user,
    required super.useLogoutDialog,
    required super.message,
    super.error,
    super.stackTrace,
  });

  /// {@macro authentication_state}
  ///
  /// Idling state
  const factory AuthenticationState.idle({
    required User user,
    bool useLogoutDialog,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = AuthenticationState$Idle;

  /// {@macro authentication_state}
  ///
  /// Processing
  const factory AuthenticationState.processing({
    required User user,
    bool useLogoutDialog,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = AuthenticationState$Processing;

  /// {@macro authentication_state}
  ///
  /// An failed has occurred
  const factory AuthenticationState.failed({
    required User user,
    bool useLogoutDialog,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = AuthenticationState$Failed;
}

/// {@macro authentication_state}
///
/// Idling state
final class AuthenticationState$Idle extends AuthenticationState {
  const AuthenticationState$Idle({
    required super.user,
    super.useLogoutDialog = false,
    super.message = 'Idle',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'idle';
}

/// {@macro authentication_state}
///
/// Processing
final class AuthenticationState$Processing extends AuthenticationState {
  const AuthenticationState$Processing({
    required super.user,
    super.useLogoutDialog = false,
    super.message = 'Processing',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'processing';
}

/// {@macro authentication_state}
///
/// Failed
final class AuthenticationState$Failed extends AuthenticationState {
  const AuthenticationState$Failed({
    required super.user,
    super.useLogoutDialog = false,
    super.message = 'Failed',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'failed';
}

/// {@macro authentication_state}
@immutable
abstract base class _$AuthenticationStateBase {
  const _$AuthenticationStateBase({
    required this.user,
    required this.useLogoutDialog,
    required this.message,
    this.error,
    this.stackTrace,
  });

  /// Type of state
  abstract final String type;

  /// User entity payload.
  @nonVirtual
  final User user;

  /// Use for show logout dialog after succeeded logout on token expired exception.
  /// Default is `false`.
  @nonVirtual
  final bool useLogoutDialog;

  /// Message or state description.
  @nonVirtual
  final String message;

  /// Error, if any.
  @nonVirtual
  final Object? error;

  /// Stack trace, if any.
  @nonVirtual
  final StackTrace? stackTrace;

  /// Is authenticated?
  bool get authenticated => user.isAuthenticated;

  /// State is processing?
  bool get isProcessing => this is AuthenticationState$Processing;

  /// Pattern matching for [AuthenticationState].
  R map<R>({
    required _AuthenticationStateMatch<R, AuthenticationState$Idle> idle,
    required _AuthenticationStateMatch<R, AuthenticationState$Processing> processing,
    required _AuthenticationStateMatch<R, AuthenticationState$Failed> failed,
  }) => switch (this) {
    AuthenticationState$Idle s => idle(s),
    AuthenticationState$Processing s => processing(s),
    AuthenticationState$Failed s => failed(s),
    _ => throw AssertionError(),
  };

  /// Pattern matching for [AuthenticationState].
  R maybeMap<R>({
    required R Function() orElse,
    _AuthenticationStateMatch<R, AuthenticationState$Idle>? idle,
    _AuthenticationStateMatch<R, AuthenticationState$Processing>? processing,
    _AuthenticationStateMatch<R, AuthenticationState$Failed>? failed,
  }) => map<R>(
    idle: idle ?? (_) => orElse(),
    processing: processing ?? (_) => orElse(),
    failed: failed ?? (_) => orElse(),
  );

  /// Pattern matching for [AuthenticationState].
  R? mapOrNull<R>({
    _AuthenticationStateMatch<R, AuthenticationState$Idle>? idle,
    _AuthenticationStateMatch<R, AuthenticationState$Processing>? processing,
    _AuthenticationStateMatch<R, AuthenticationState$Failed>? failed,
  }) => map<R?>(idle: idle ?? (_) => null, processing: processing ?? (_) => null, failed: failed ?? (_) => null);

  @override
  int get hashCode => Object.hash(type, user, useLogoutDialog);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _$AuthenticationStateBase &&
        other.useLogoutDialog == useLogoutDialog &&
        identical(other.user, user) &&
        other.type == type;
  }

  @override
  String toString() => 'AuthenticationState.$type{message: $message}';
}

/// {@template authentication_controller}
/// Controller for authentication feature.
///
/// This controller is responsible for handling authentication state and events
/// such as sign in, sign out, and session restoration.
/// {@endtemplate}
final class AuthenticationController extends StateController<AuthenticationState> with DroppableControllerHandler {
  /// {@macro authentication_controller}
  AuthenticationController({
    required IAuthenticationRepository repository,
    super.initialState = const AuthenticationState.idle(user: User.unauthenticated()),
  }) : _repository = repository {
    _userSubscription = repository
        .userChanges()
        .where((user) => !identical(user, state.user))
        .map<AuthenticationState>((u) => AuthenticationState.idle(user: u))
        .listen(setState, cancelOnError: false);
  }

  final IAuthenticationRepository _repository;
  StreamSubscription<AuthenticationState>? _userSubscription;

  /// Restore the session from the cache.
  Future<void> restore() => handle(
    () async {
      setState(AuthenticationState.processing(user: state.user, message: 'Restoring session'));
      l.i('Restoring session...');
      final user = await _repository.restore();
      setState(AuthenticationState.idle(user: user ?? const User.unauthenticated()));
    },
    error: (error, _) async {
      setState(
        AuthenticationState.idle(
          user: state.user,
          // ErrorUtil.formatMessage(error)
          error: kDebugMode ? 'Restore Error: $error' : 'Restore Error',
        ),
      );
    },
    name: 'restore',
  );

  /// Sign in with the given [data].
  Future<void> signIn(
    SignInData data, {
    void Function()? onDone,
    void Function()? onProcessing,
    void Function(Object?)? onError,
    void Function(User user)? onSucceeded,
  }) => handle(
    () async {
      if (state.user.isAuthenticated) {
        AuthenticationState.processing(user: state.user, message: 'Logging out');
        l.i('Logging out user #${state.user.id}...');
        onProcessing?.call();
        await _repository.signOut().onError((e, _) {
          onError?.call(e);
          onDone?.call();
        });
        const AuthenticationState.processing(user: User.unauthenticated(), message: 'Successfully logged out');
      }
      setState(AuthenticationState.processing(user: state.user, message: 'Signing in user'));
      l.i('Signing in user...');
      onProcessing?.call();
      final user = await _repository.signIn(data);
      setState(AuthenticationState.idle(user: user, message: 'Successfully signed in user'));
      onSucceeded?.call(user);
    },
    error: (error, _) async {
      setState(
        AuthenticationState.failed(user: state.user, error: 'Failed to signing in: ${ErrorUtil.formatMessage(error)}'),
      );
    },
    done: () async => setState(AuthenticationState.idle(user: state.user)),
    name: 'signIn',
  );

  /// Sign out.
  Future<void> signOut({
    void Function(Object error)? onError,
    void Function()? onProcessing,
    void Function()? onSucceeded,
    void Function()? onDone,
    bool fromAllDevices = false,
    bool useLogoutDialog = false,
    bool? withOutToken,
  }) => handle(
    () async {
      // if (state.user.isNotAuthenticated) return; // Already signed out.
      setState(
        AuthenticationState.processing(user: state.user, useLogoutDialog: useLogoutDialog, message: 'Signing out'),
      );
      l.i('Signing out user #${state.user.id}...');
      onProcessing?.call();
      await _repository.signOut();
      setState(AuthenticationState.idle(user: const User.unauthenticated(), useLogoutDialog: state.useLogoutDialog));
      onSucceeded?.call();
    },
    error: (error, _) async {
      setState(
        AuthenticationState.failed(
          user: const User.unauthenticated(),
          useLogoutDialog: state.useLogoutDialog,
          error: 'Failed to sign out: ${ErrorUtil.formatMessage(error)}',
        ),
      );
      onError?.call(error);
    },
    done: () async {
      setState(AuthenticationState.idle(user: state.user, useLogoutDialog: state.useLogoutDialog));
      onDone?.call();
    },
    name: 'signOut',
    meta: <String, Object?>{'useLogoutDialog': useLogoutDialog},
  );

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
