import 'package:meta/meta.dart';

/// User id type.
typedef UserID = String;

/// {@template user}
/// The user entry model.
/// {@endtemplate}
@immutable
sealed class User with _UserPatternMatching, _UserShortcuts {
  /// {@macro user}
  const User._();

  /// {@macro user}
  @literal
  const factory User.unauthenticated() = UnauthenticatedUser;

  /// {@macro user}
  const factory User.authenticated({required UserID id, required String token}) = AuthenticatedUser;

  /// {@macro user}
  factory User.fromJson(Map<String, Object?> json) => switch (json['id']) {
    UserID id => AuthenticatedUser(
      id: id,
      token: switch (json['token']) {
        String token when token.isNotEmpty => token,
        _ => '',
      },
    ),
    _ => const UnauthenticatedUser(),
  };

  /// The user's id.
  abstract final UserID? id;

  /// The user's access token.
  abstract final String? token;

  /// Convert user to `JSON`.
  Map<String, Object?> toJson();
}

/// {@macro user}
///
/// Unauthenticated user.
class UnauthenticatedUser extends User {
  /// {@macro user}
  const UnauthenticatedUser() : super._();

  /// {@macro user}
  // ignore: avoid_unused_constructor_parameters
  factory UnauthenticatedUser.fromJson(Map<String, Object?> json) => const UnauthenticatedUser();

  @override
  UserID? get id => null;

  @override
  String? get token => null;

  @override
  bool get isAuthenticated => false;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'user',
    'authenticated': false,
    'status': 'unauthenticated',
    'id': null,
    'token': null,
  };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) => unauthenticated(this);

  @override
  User copyWith({UserID? id, String? token}) =>
      id != null ? AuthenticatedUser(id: id, token: token ?? '') : const UnauthenticatedUser();

  @override
  int get hashCode => -1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UnauthenticatedUser && id == other.id && token == other.token;

  @override
  String toString() => 'UnauthenticatedUser{}';
}

/// {@macro user}
final class AuthenticatedUser extends User {
  /// {@macro user}
  const AuthenticatedUser({required this.id, required this.token}) : super._();

  /// {@macro user}
  factory AuthenticatedUser.fromJson(Map<String, Object?> json) {
    if (json.isEmpty) throw FormatException('AuthenticatedUser.fromJson | JSON is empty', json);
    if (json case <String, Object?>{'id': UserID id}) {
      return AuthenticatedUser(
        id: id,
        token: switch (json['token']) {
          String token when token.isNotEmpty => token,
          _ => '',
        },
      );
    }
    throw FormatException('AuthenticatedUser.fromJson | JSON is invalid', json);
  }

  @override
  @nonVirtual
  final UserID id;

  @override
  @nonVirtual
  final String token;

  @override
  @nonVirtual
  bool get isAuthenticated => true;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'user',
    'authenticated': true,
    'status': 'authenticated',
    'id': id,
    'token': token,
  };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) => authenticated(this);

  @useResult
  @override
  AuthenticatedUser copyWith({UserID? id, String? token}) =>
      AuthenticatedUser(id: id ?? this.id, token: token ?? this.token);

  @override
  int get hashCode => Object.hash(id, token);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthenticatedUser && id == other.id && token == other.token;

  @override
  String toString() => 'AuthenticatedUser.$id{id: $id, token: $token}';
}

mixin _UserPatternMatching {
  /// Pattern matching on [User] subclasses.
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  });

  /// Pattern matching on [User] subclasses.
  T maybeMap<T>({
    required T Function() orElse,
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) => map<T>(
    unauthenticated: (user) => unauthenticated?.call(user) ?? orElse(),
    authenticated: (user) => authenticated?.call(user) ?? orElse(),
  );

  /// Pattern matching on [User] subclasses.
  T? mapOrNull<T>({
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) => map<T?>(
    unauthenticated: (user) => unauthenticated?.call(user),
    authenticated: (user) => authenticated?.call(user),
  );
}

mixin _UserShortcuts on _UserPatternMatching {
  /// User is authenticated.
  bool get isAuthenticated;

  /// User is not authenticated.
  bool get isNotAuthenticated => !isAuthenticated;

  /// Copy with new values.
  User copyWith({UserID? id, String? token});
}
