import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWasm, kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/generated/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// {@template sentry_meta_processor}
/// SentryMetaProcessor is an [EventProcessor] that adds metadata to the
/// Sentry event.
/// {@endtemplate}
@immutable
class SentryMetaProcessor implements EventProcessor {
  /// {@macro sentry_meta_processor}
  const SentryMetaProcessor({required Dependencies dependencies}) : _dependencies = dependencies;

  final Dependencies _dependencies;

  @override
  FutureOr<SentryEvent?> apply(SentryEvent event, Hint hint) {
    final user = _dependencies.authenticationController.state.user;
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final flutterView = dispatcher.views.firstOrNull;
    return event
      ..environment = Config.environment.name
      ..release = _dependencies.metadata.appVersion
      ..dist = Pubspec.version.build.join('-')
      ..user = user.id != null
          ? SentryUser(id: user.id /* username: user.name, email: user.email, name: user.name */)
          : null
      ..level = event.level ?? SentryLevel.info
      ..logger = event.logger ?? 'AppOrOrgName'
      ..contexts = (event.contexts
        ..device =
            event.contexts.device ??
            SentryDevice(
              orientation: switch (flutterView?.physicalSize) {
                ui.Size(width: var w, height: var h) when w > h => SentryOrientation.landscape,
                _ => SentryOrientation.portrait,
              },
              simulator: event.contexts.device?.simulator,
              screenDensity: flutterView?.devicePixelRatio,
              screenWidthPixels: flutterView?.physicalSize.width.toInt() ?? 0,
              screenHeightPixels: flutterView?.physicalSize.height.toInt() ?? 0,
              screenDpi: switch (flutterView?.devicePixelRatio) {
                double dpr when dpr > 0 => (dpr * 160).round(),
                _ => null,
              },
            )
        ..operatingSystem =
            event.contexts.operatingSystem ??
            SentryOperatingSystem(
              name: defaultTargetPlatform.name,
              theme: dispatcher.platformBrightness.name,
              version: event.contexts.operatingSystem?.version ?? _dependencies.metadata.deviceVersion,
            )
        ..app =
            event.contexts.app ??
            SentryApp(
              name: _dependencies.metadata.appName,
              version: Pubspec.version.canonical,
              build: Pubspec.version.build.join('-'),
              buildType: _dependencies.metadata.isRelease ? 'release' : 'debug',
              startTime: _dependencies.metadata.appLaunchedTimestamp.toUtc(),
              textScale: dispatcher.textScaleFactor,
            ))
      ..tags = <String, String>{...?event.tags}
      /* ..breadcrumbs = <Breadcrumb>[
        if (event.contexts['current_client'] case String clientID when clientID.isNotEmpty)
          Breadcrumb(
            category: 'clients',
            level: SentryLevel.info,
            message: 'Current client',
            type: 'state',
            data: {'client_id': clientID},
          ),
        ...?event.breadcrumbs,
      ] */
      ..platform =
          '${defaultTargetPlatform.name.toLowerCase()}'
          '-'
          '${kIsWeb
              ? kIsWasm
                    ? 'wasm'
                    : 'web'
              : 'native'}';
  }
}
