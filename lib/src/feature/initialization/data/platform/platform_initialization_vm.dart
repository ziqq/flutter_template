import 'dart:io' as io;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:l/l.dart';

Future<void> $platformInitialization() {
  switch (defaultTargetPlatform) {
    case .windows:
      l.d('Platform is Windows');
    case .macOS:
      l.d('Platform is macOS');
    case .iOS:
      l.d('Platform is iOS');
    case .android:
      l.d('Platform is Android');
    case .linux:
      l.d('Platform is Linux');
    case .fuchsia:
      l.d('Platform is Fuchsia');
  }

  // Complete time check for platform initialization.
  return io.Platform.isAndroid || io.Platform.isIOS ? _mobileInitialization() : _desktopInitialization();
}

Future<void> _mobileInitialization() async {
  final view = ui.PlatformDispatcher.instance.views.firstOrNull;
  if (view != null) {
    final size = view.physicalSize / view.devicePixelRatio;
    if (size.shortestSide < 600) {
      l.d('Device is a phone with size: $size, setting portait orientation');
      await SystemChrome.setPreferredOrientations([.portraitUp, .portraitDown]);
    } else {
      l.d('Device is a tablet with size: $size, setting any orientation');
      await SystemChrome.setPreferredOrientations([.portraitUp, .portraitDown, .landscapeLeft, .landscapeRight]);
    }
  }
}

Future<void> _desktopInitialization() async {
  l.d('Device is a desktop');
  // Must add this line.
  /* await windowManager.ensureInitialized();
  final windowOptions = WindowOptions(
    minimumSize: const Size(360, 480),
    size: const Size(960, 800),
    maximumSize: const Size(1440, 1080),
    center: true,
    backgroundColor: PlatformDispatcher.instance.platformBrightness == Brightness.dark
        ? ThemeData.dark().colorScheme.surfaceContainerHighest
        : ThemeData.light().colorScheme.surfaceContainerHighest,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    /* alwaysOnTop: true, */
    fullScreen: false,
    title: 'Vexus',
  );
  await windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      if (io.Platform.isMacOS) {
        await windowManager.setMovable(true);
      }
      await windowManager.setMaximizable(false);
      await windowManager.show();
      await windowManager.focus();
    },
  ); */
}

/// Initializes Firebase App Check for Android and iOS platforms.
Future<void> $firebaseAppCheckInitialization() async {
  if (defaultTargetPlatform == .android) {
    /* await fb_app_check.FirebaseAppCheck.instance.activate(
      webProvider: fb_app_check.ReCaptchaV3Provider('6LdJ88EqAAAAAKrj3kOH2BkDwLb2MLMre5BTYM00'),
      androidProvider: switch (Config.environment) {
        .production => fb_app_check.AndroidProvider.playIntegrity,
        .staging => fb_app_check.AndroidProvider.playIntegrity,
        .development => fb_app_check.AndroidProvider.debug,
        .testing => fb_app_check.AndroidProvider.debug,
        .local => fb_app_check.AndroidProvider.debug,
      },
    ); */
  } else if (defaultTargetPlatform == .iOS || defaultTargetPlatform == .macOS) {
    /* await fb_app_check.FirebaseAppCheck.instance.activate(
      webProvider: fb_app_check.ReCaptchaV3Provider('6LdJ88EqAAAAAKrj3kOH2BkDwLb2MLMre5BTYM00',
      appleProvider: switch (Config.environment) {
        Config.environment.production => fb_app_check.AppleProvider.appAttestWithDeviceCheckFallback,
        Config.environment.staging => fb_app_check.AppleProvider.appAttestWithDeviceCheckFallback,
        Config.environment.development => fb_app_check.AppleProvider.debug,
        Config.environment.testing => fb_app_check.AppleProvider.debug,
        Config.environment.local => fb_app_check.AppleProvider.debug,
      },
    ); */
  } else if (defaultTargetPlatform == .linux) {
    // Not supported yet
  } else if (defaultTargetPlatform == .windows) {
    // Not supported yet
  }
}

/// A notifier to track the loading progress of the app initialization.
final $initializationProgress = ValueNotifier<({int progress, String message})>((progress: 0, message: ''));

/// Stub function to update loading progress.
void $updateLoadingProgress({int progress = 100, String message = ''}) {
  $initializationProgress.value = (progress: progress, message: message);
}

/// Stub function to remove the loading widget.
void $removeLoadingWidget() {}
