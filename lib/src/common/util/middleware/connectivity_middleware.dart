/*
 * Date: 02 February 2026
 */

import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/util/connectivity/connectivity_service.dart';
import 'package:meta/meta.dart';

/// {@template connectivity_middleware}
/// Middleware for handling connectivity state and blocking requests when offline.
/// This middleware checks the connectivity status before processing API requests.
/// {@endtemplate}
@immutable
class ConnectivityMiddleware {
  /// {@macro connectivity_middleware}
  const ConnectivityMiddleware({required this.controller});

  /// Connectivity status controller.
  final ConnectivityStatusController controller;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    if (controller.value == ConnectivityStatus.offline) throw const ApiException$Offline();
    return innerHandler(request, context);
  };
}

/// {@template connection_middleware}
/// Middleware for handling connectivity state and blocking requests when offline.
/// This middleware checks the connectivity status before processing API requests.
/// {@endtemplate}
/* final class ConnectivityMiddleware {
  /// {@macro connection_middleware}
  const ConnectivityMiddleware({required this.connectivity, this.onSuccess, this.onSocketException});

  /// Connectivity status controller.
  final ValueNotifier<ConnectivityStatus> connectivity;

  final void Function()? onSuccess;
  final void Function()? onSocketException;

  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) async {
    if (connectivity.value == ConnectivityStatus.offline) throw const ApiException$Offline();
    try {
      final res = await innerHandler(request, context);
      if (connectivity.value == ConnectivityStatus.offline) connectivity.value = ConnectivityStatus.online;
      onSuccess?.call();
      return res;
    } on Object catch (e) {
      if (_isOfflineError(e)) {
        if (connectivity.value == ConnectivityStatus.online) connectivity.value = ConnectivityStatus.offline;
        onSocketException?.call();
      }
      rethrow;
    }
  };

  /// Detect if the error is related to connectivity issues.
  bool _isOfflineError(Object error) => switch (error) {
    io.SocketException() => true,
    _ => false,
  };
}
 */
