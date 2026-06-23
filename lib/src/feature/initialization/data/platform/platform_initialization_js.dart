//import 'dart:js_interop';
//import 'dart:js_interop_unsafe';

import 'dart:async' show Timer;
import 'dart:js_interop';

// import 'package: file_picker/_internal/file_picker_web.dart';
// import 'package:firebase_app_check/firebase_app_check.dart'as fb_app_check;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:l/l.dart';
import 'package:web/web.dart' as web;

extension type $JSWindow._(JSObject _) implements JSObject {
  /// Update loading progress.
  external void updateLoadingProgress(int progress, String message);

  /// Removes the loading indicator.
  external void removeLoadingIndicator();
}

@JS('window')
external $JSWindow get window;

Future<void> $platformInitialization() async {
  try {
    // Set the URL strategy
    usePathUrlStrategy();
  } on Object catch (e, s) {
    l.w('Failed to set URL strategy: $e', s);
  }

  try {
    if (kIsWeb) BrowserContextMenu.disableContextMenu().ignore();
  } on Object catch (e, s) {
    l.w('Failed to disable browser context menu: $e', s);
  }

  try {
    // Register the FilePickerWeb.
    // if (kIsWeb) FilePickerWeb.registerWith(Registrar());
  } on Object catch (e, s) {
    l.w('Failed to register FilePickerWeb: $e', s);
  }

  // Remove splash screen after 1 second delay
  Timer(const Duration(seconds: 1), () {
    try {
      final loading = web.document.getElementsByClassName('loading');
      for (var i = loading.length - 1; i >= 0; i--) {
        loading.item(i)?.remove();
      }
    } on Object catch (e, s) {
      l.w('Failed to remove splash screen: $e', s);
    }
  });

  // Current os check
  try {
    switch (defaultTargetPlatform) {
      case .windows:
        l.d('Device is Windows.');
      case .macOS:
        l.d('Device is macOS.');
        web.window.visualViewport?.addEventListener(
          'resize',
          (web.Event e) {
            web.window.dispatchEvent(web.Event('resize'));
          }.toJS,
        );
      case .iOS:
        l.d('Device is iOS.');
        web.window.visualViewport?.addEventListener(
          'resize',
          (web.Event e) {
            web.window.dispatchEvent(web.Event('resize'));
          }.toJS,
        );
      case .android:
        l.d('Device is Android.');
      case .linux:
        l.d('Device is Linux.');
      case .fuchsia:
        l.d('Device is Fuchsia.');
    }
  } on Object catch (e, s) {
    l.w('Error during platform pre initialization: $e', s);
  }
}

/// Update the loading progress on the web platform.
void $updateLoadingProgress({int progress = 100, String message = ''}) {
  window.updateLoadingProgress(progress, message);
}

/// Remove the loading widget from the web platform.
void $removeLoadingWidget() => window.removeLoadingIndicator();
