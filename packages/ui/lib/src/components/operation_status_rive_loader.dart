/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 */

import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

/// Loads and owns the shared operation-status animation for one messenger.
///
/// Call [load] when Rive is selected. Repeated calls share the first attempt,
/// including a failed one. Listeners are notified once when [file] is ready;
/// failure leaves it null so the host continues displaying its standard fallback.
/// Dispose the loader after its indicator children have released their controllers.
class OperationStatusRiveLoader extends ChangeNotifier {
  /// Creates an idle loader without initializing Rive or reading the asset.
  OperationStatusRiveLoader();

  rive.File? _file;
  Future<void>? _loading;
  bool _disposed = false;

  /// The borrowed animation file, or null before success and after disposal.
  ///
  /// Consumers must not dispose this file or retain controllers after the loader
  /// is disposed. A failed load also leaves this value null.
  rive.File? get file => _file;

  /// Initializes Rive and loads the package asset once from [bundle].
  ///
  /// Completes when the attempt and any pending IO finish, including failures.
  /// Disposal suppresses the result but does not complete pending IO early.
  /// Load failures are logged rather than rethrown; inspect [file] for success.
  /// Later calls reuse the same future and ignore a different bundle. A new
  /// loader is required to retry. Throws [StateError] if already disposed.
  Future<void> load(AssetBundle bundle) {
    if (_disposed) throw StateError('OperationStatusRiveLoader is disposed.');
    return _loading ??= _load(bundle);
  }

  Future<void> _load(AssetBundle bundle) async {
    try {
      await rive.RiveNative.init();
      if (_disposed) return;
      final file = await rive.File.asset(
        'packages/ui/assets/check_error.riv',
        riveFactory: rive.Factory.flutter,
        bundle: bundle,
      );
      if (_disposed) {
        file?.dispose();
        return;
      }
      if (file == null) throw StateError('The operation status animation could not be decoded.');
      _file = file;
      notifyListeners();
    } on Object catch (error, stackTrace) {
      dev.log(
        'Rive status animation unavailable; using the standard indicator.',
        name: 'OperationStatusRiveLoader',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Releases the cached file and suppresses notifications from pending work.
  ///
  /// Asset IO cannot be interrupted; a file decoded after disposal is released
  /// immediately instead of being published to listeners.
  @override
  void dispose() {
    _disposed = true;
    try {
      _file?.dispose();
    } finally {
      _file = null;
      super.dispose();
    }
  }
}
