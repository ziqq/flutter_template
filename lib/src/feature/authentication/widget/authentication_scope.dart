import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:flutter_template_name/src/feature/authentication/controller/authentication_controller.dart';
import 'package:flutter_template_name/src/feature/authentication/model/sign_in_data.dart';
import 'package:flutter_template_name/src/feature/authentication/model/user.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/signup_screen.dart';
import 'package:l/l.dart';

/// {@template authentication_scope}
/// AuthenticationScope widget.
/// {@endtemplate}
class AuthenticationScope extends StatefulWidget {
  /// {@macro authentication_scope}
  const AuthenticationScope({required this.child, super.key});

  /// The widget below this widget in the tree.
  final Widget child;

  /// Get the current [AuthenticationController]
  static AuthenticationController of(BuildContext context) => _InheritedAuthentication.of(context).scope._controller;

  /// Get the current [AuthenticationState]
  static AuthenticationState stateOf(BuildContext context, {bool listen = true}) => _InheritedAuthentication.of(
    context,
    aspect: listen ? _AutenticationAspect.state : _AutenticationAspect.none,
  ).state;

  /// Get the current [User]
  static User userOf(BuildContext context, {bool listen = true}) =>
      _InheritedAuthentication.of(context, aspect: listen ? _AutenticationAspect.user : _AutenticationAspect.none).user;

  /// Check if the user is authenticated and call the given function [authenticated]
  /// if the user is authenticated.
  ///
  /// If the user is not authenticated, call the given callback function [orElse].
  static AuthenticatedUser? authenticatedUserOr(
    BuildContext context, {
    void Function(AuthenticatedUser user)? authenticated,
    void Function(AuthenticationController controller)? orElse,
  }) {
    final currentUser = userOf(context, listen: false);
    if (currentUser case AuthenticatedUser user) {
      authenticated?.call(user);
      return user;
    } else if (orElse != null) {
      orElse.call(of(context));
    }
    return null;
  }

  /// Sign-In
  static Future<void> signIn(
    BuildContext context,
    SignInData data, {
    void Function()? onDone,
    void Function()? onProcessing,
    void Function(Object?)? onError,
    void Function(User user)? onSucceeded,
  }) =>
      of(context).signIn(data, onProcessing: onProcessing, onSucceeded: onSucceeded, onError: onError, onDone: onDone);

  /// Sign-Out
  static Future<void> signOut(
    BuildContext context, {
    void Function(Object error)? onError,
    void Function()? onProcessing,
    void Function()? onSucceeded,
    void Function()? onDone,
    bool fromAllDevices = false,
    bool useLogoutDialog = false,
    bool? withOutToken,
  }) => of(context).signOut(
    onProcessing: onProcessing,
    onSucceeded: onSucceeded,
    onError: onError,
    onDone: onDone,
    withOutToken: withOutToken,
    fromAllDevices: fromAllDevices,
    useLogoutDialog: useLogoutDialog,
  );

  /// Change account
  /* static Future<void> changeAccount(
    BuildContext context,
    TokenPair tokenPair, {
    void Function(User user)? onSucceeded,
    void Function()? onDone,
  }) => of(context).changeAccount(tokenPair, onSucceeded: onSucceeded, onDone: onDone); */

  /// Refresh user data
  /* static Future<void> refresh(
    BuildContext context, {
    void Function(User user)? onSucceeded,
    void Function(Object? error)? onError,
    void Function()? onProcessing,
    void Function()? onDone,
  }) => of(context).refresh(onProcessing: onProcessing, onSucceeded: onSucceeded, onError: onError, onDone: onDone); */

  @override
  State<AuthenticationScope> createState() => _AuthenticationScopeState();
}

/// State for widget AuthenticationScope.
class _AuthenticationScopeState extends State<AuthenticationScope> {
  late final AuthenticationController _controller;
  late AnalyticsTracker _analytics;
  late AuthenticationState _state;
  StreamSubscription<String>? _tokenFCMSubscription;

  /// Current user.
  User get user => _state.user;

  @override
  void initState() {
    super.initState();
    final dependecies = Dependencies.of(context);
    _controller = dependecies.authenticationController;
    _controller.addListener(_onStateChanged);
    _analytics = dependecies.analytics;
    _state = _controller.state;
    if (Firebase.apps.isNotEmpty) {
      void onError(Object? e, StackTrace s) {
        ErrorUtil.logError(e ?? Exception('Error listening to FCM token refresh'), s).ignore();
      }

      _tokenFCMSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefreshed)..onError(onError);
    }
    l.d('Current user: $user');
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _tokenFCMSubscription?.cancel();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    if (_controller.state.isProcessing) return;

    final prevState = _state;
    final nextState = _controller.state;

    if (!identical(prevState.user.id, nextState.user.id)) {
      l.d('User changed: ${prevState.user} -> ${nextState.user}');
      final u = nextState.user;
      /*
        final nextUserID = u.id;
        final prevUserID = prevState.user.id;

        if (prevUserID != null && nextUserID != null) {
          l.i('Re-subscribing push notifications for user #$nextUserID');
          final dependecies = Dependencies.of(context);
          dependecies.authenticationRepository
              .reSubscribeToNotifications(id: nextUserID, skipCheckTimestamp: true)
              .onError((e, s) => ErrorUtil.logError(e ?? Exception('Re-subscrib push notifications error'), s).ignore())
              .ignore();
        }
      */

      if (u.isAuthenticated) {
        _analytics
          ..setUserID(u.id.toString())
          ..setConsent(u.isAuthenticated).ignore()
          ..logEvent(
            'authentication',
            'authenticated',
            parameters: <String, String>{
              // 'name': u.name ?? u.id?.toString() ?? '',
              // 'role': u.role.toString(),
            },
          ).ignore();
      } else {
        _analytics
          ..setUserID(null)
          ..setConsent(false).ignore()
          ..logEvent('authentication', 'not_unauthenticated').ignore();
      }
    }

    _state = nextState;
    setState(() {});
  }

  void _onTokenRefreshed(String token) {
    // final dependecies = Dependencies.of(context);
    final id = _controller.state.user.id;
    if (id == null) {
      l.i('FCM token refreshed without authenticated user, skipping re-subscribe');
      return;
    }

    /* l.i('FCM token refreshed, re-subscribing push notifications');
    dependecies.authenticationRepository
        .reSubscribeToNotifications(token: token, id: id, skipCheckTimestamp: true)
        .onError((e, s) => ErrorUtil.logError(e ?? Exception('FCM token refresh error'), s).ignore())
        .ignore(); */
  }

  @override
  Widget build(BuildContext context) => _InheritedAuthentication(
    // With this local key, the widget will rebuild when the user ID changes.
    // This is important to drop an rebuild then whole "widget tree"
    // when the user login, changed or logout.
    key: ValueKey<UserID?>(user.id),
    scope: this,
    state: _state,
    child: user.isAuthenticated
        ? widget.child
        : /* AuthenticationNavigator(pages: const [AuthOnboardingPage()]) */ const SignUpScreen(),
  );
}

enum _AutenticationAspect {
  /// Do not notify about changes.
  none,

  /// UserID of the user has changed.
  id,

  /// User data has changed.
  user,

  /// Authentication state has changed.
  state,
}

/// Inherited widget for quick access in the element tree.
class _InheritedAuthentication extends InheritedModel<_AutenticationAspect> {
  const _InheritedAuthentication({required this.state, required this.scope, required super.child, super.key});

  /// The authentication state from the controller.
  /// This is the state of the authentication controller [AuthenticationController].
  final AuthenticationState state;

  /// Curent user provided by the authentication scope.
  /// This is the user that is currently loged in or unauthenticated.
  User get user => state.user;

  /// This authentication scope state.
  /// This is the state of the authentication scope.
  final _AuthenticationScopeState scope;

  static _InheritedAuthentication? maybeOf(
    BuildContext context, {
    _AutenticationAspect aspect = _AutenticationAspect.none,
  }) => switch (aspect) {
    // Do not notify about changes.
    _AutenticationAspect.none => context.getInheritedWidgetOfExactType<_InheritedAuthentication>(),

    // Notify about every change.
    _AutenticationAspect.state => context.dependOnInheritedWidgetOfExactType<_InheritedAuthentication>(),

    // Notify about changes in user ID.
    _AutenticationAspect.id => InheritedModel.inheritFrom<_InheritedAuthentication>(
      context,
      aspect: _AutenticationAspect.id,
    ),

    // Notify about changes in user data.
    _AutenticationAspect.user => InheritedModel.inheritFrom<_InheritedAuthentication>(
      context,
      aspect: _AutenticationAspect.user,
    ),
  };

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget '
        'a _InheritedAuthentication of the exact type',
    'out_of_scope',
  );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// For example: `AuthenticationScope.of(context)`.
  // ignore: unused_element_parameter
  static _InheritedAuthentication of(BuildContext context, {_AutenticationAspect aspect = _AutenticationAspect.none}) =>
      maybeOf(context, aspect: aspect) ?? _notFoundInheritedWidgetOfExactType();

  @override
  bool updateShouldNotify(covariant _InheritedAuthentication oldWidget) => !identical(oldWidget.user, user);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedAuthentication oldWidget,
    Set<_AutenticationAspect> dependencies,
  ) {
    for (final d in dependencies) {
      switch (d) {
        case _AutenticationAspect.id when user.id != oldWidget.user.id:
          // Notify about changes in user ID.
          return true;
        case _AutenticationAspect.user when user != oldWidget.user:
          // Notify about changes in user data.
          return true;
        case _AutenticationAspect.state when !identical(oldWidget.state, state):
          // Notify about changes in authentication state.
          return true;
        default:
          continue;
      }
    }
    return false;
  }
}
