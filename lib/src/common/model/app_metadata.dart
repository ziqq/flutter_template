import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/util/screen_util.dart' show ScreenUtil;
import 'package:l/l.dart';
import 'package:platform_info/platform_info.dart' as platform_info;

/// {@template app_metadata}
/// App metadata
/// {@endtemplate}
@immutable
class AppMetadata {
  /// {@macro app_metadata}
  const AppMetadata({
    required this.isWeb,
    required this.isRelease,
    required this.appVersion,
    required this.appVersionMajor,
    required this.appVersionMinor,
    required this.appVersionPatch,
    required this.appBuildTimestamp,
    required this.appName,
    required this.operatingSystem,
    required this.operatingSystemManufacturer,
    required this.processorsCount,
    required this.locale,
    required this.deviceVersion,
    required this.deviceScreenSize,
    required this.hasGmsServices,
    required this.hasHmsServices,
    required this.appLaunchedTimestamp,
    this.androidInfo,
    this.iosInfo,
  });

  /// Method channel for platform metadata.
  /// Implementation on Android should return map with keys 'gms' and 'hms' with boolean values
  /// indicating presence of `Google Mobile Services` and `Huawei Mobile Services` respectively.
  /// See Android implementation in `/android/app/src/main/kotlin/ru/tetrakda/MainActivity.kt`
  static const _channel = MethodChannel('ru.beautybox.twa/app_metadata');

  /// Is web platform
  final bool isWeb;

  /// Is release build
  final bool isRelease;

  /// App version
  final String appVersion;

  /// App version major
  final int appVersionMajor;

  /// App version minor
  final int appVersionMinor;

  /// App version patch
  final int appVersionPatch;

  /// App build timestamp
  final DateTime appBuildTimestamp;

  /// App name
  final String appName;

  /// Operating system
  final String operatingSystem;

  /// Manufacturer of the device operating system, e.g. Google, Huawei, Apple, etc.
  final String operatingSystemManufacturer;

  /// Processors count
  final int processorsCount;

  /// Locale
  final String locale;

  /// Device representation
  final String deviceVersion;

  /// Device logical screen size
  final String deviceScreenSize;

  /// Return `true` if devece with Google Mobile Services
  final bool hasGmsServices;

  /// Return `true` if devece with Huawei Mobile Services
  final bool hasHmsServices;

  /// App launched timestamp
  final DateTime appLaunchedTimestamp;

  /// Android device info
  final AndroidDeviceInfo? androidInfo;

  /// iOS device info
  final IosDeviceInfo? iosInfo;

  /// Platform version
  String get platformVersion => platform_info.platform.version;

  /// Platform info
  BaseDeviceInfo? get platformInfo => switch (defaultTargetPlatform) {
    .android => androidInfo,
    .iOS => iosInfo,
    _ => null,
  };

  /// Convert to string
  String toJsonString() {
    // String formatDate(DateTime date) => date.toUtc().toIso8601String();
    final buffer = StringBuffer()
      // ..writeln('"client": "flutter", ')
      ..writeln('"locale": "$locale", ')
      ..writeln('"platform": ${kIsWeb ? '"web"' : '"native"'}, ')
      ..writeln('"environment": "${Config.environment.name}", ')
      ..writeln('"is_release": $isRelease, ')
      ..writeln('"app_name": "$appName", ')
      ..writeln('"app_version": "$appVersion", ')
      // ..writeln('"app_build_timestamp": "${formatDate(appBuildTimestamp)}", ')
      /* ..writeln(
        '"app_launched_timestamp": "${formatDate(appLaunchedTimestamp)}", ',
      ) */
      ..writeln('"operating_system": "$operatingSystem", ')
      ..writeln('"operating_system_manufacturer": "$operatingSystemManufacturer", ')
      ..writeln('"processors_count": $processorsCount, ')
      ..writeln('"device_version": $deviceVersion, ')
      ..writeln('"device_screen_size": "$deviceScreenSize"');
    if (platform_info.platform.android) {
      buffer
        ..writeln(', "device_services_gms": ${hasGmsServices ? 'true' : 'false'}')
        ..writeln(', "device_services_hms": ${hasHmsServices ? 'true' : 'false'}');
    }
    return buffer.toString();
  }

  /// Convert to headers
  Map<String, String> toHeaders() => <String, String>{
    'Accept-Language': locale,
    'X-Client': 'Flutter',
    'X-Meta-Platform': kIsWeb ? 'web' : 'native',
    'X-Meta-Environment': Config.environment.name,
    'X-Meta-Is-Release': isRelease ? 'true' : 'false',
    'X-Meta-App-Version': appVersion,
    'X-Meta-App-Version-Major': appVersionMajor.toString(),
    'X-Meta-App-Version-Minor': appVersionMinor.toString(),
    'X-Meta-App-Version-Patch': appVersionPatch.toString(),
    'X-Meta-App-Build-Timestamp': appBuildTimestamp.toUtc().toIso8601String(),
    'X-Meta-App-Name': appName,
    'X-Meta-Operating-System': operatingSystem,
    'X-Meta-Operating-System-Manufacturer': operatingSystemManufacturer,
    'X-Meta-Processors-Count': processorsCount.toString(),
    'X-Meta-Locale': locale,
    'X-Meta-Device-Version': deviceVersion,
    'X-Meta-Device-Screen-Size': deviceScreenSize,
    'X-Meta-Device-GMS': hasGmsServices ? 'true' : 'false',
    'X-Meta-Device-HMS': hasHmsServices ? 'true' : 'false',
    'X-Meta-App-Launched-Timestamp': appLaunchedTimestamp.toUtc().toIso8601String(),
  };

  /// Initialize platform metadata
  static Future<AppMetadata> platform() async {
    final deviceInfo = DeviceInfoPlugin();

    IosDeviceInfo? iosInfo;
    AndroidDeviceInfo? androidInfo;

    final mobileServices = await _getAndroidMobileServices();
    if (defaultTargetPlatform == .iOS) iosInfo = await deviceInfo.iosInfo;
    if (defaultTargetPlatform == .android) androidInfo = await deviceInfo.androidInfo;

    return AppMetadata(
      iosInfo: iosInfo,
      androidInfo: androidInfo,
      isWeb: platform_info.platform.desktop,
      isRelease: platform_info.platform.buildMode.release,
      appName: Pubspec.name,
      appVersion: Pubspec.version.representation,
      appVersionMajor: Pubspec.version.major,
      appVersionMinor: Pubspec.version.minor,
      appVersionPatch: Pubspec.version.patch,
      appBuildTimestamp: Pubspec.timestamp,
      appLaunchedTimestamp: DateTime.now().toLocal().toUtc(),
      deviceVersion: platform_info.platform.version,
      deviceScreenSize: ScreenUtil.screenSize().representation,
      processorsCount: platform_info.platform.numberOfProcessors,
      operatingSystem: platform_info.platform.operatingSystem.name,
      operatingSystemManufacturer: androidInfo?.manufacturer ?? 'Apple',
      locale: platform_info.platform.locale,
      hasGmsServices: mobileServices.gms,
      hasHmsServices: mobileServices.hms,
    );
  }

  /// Get Android mobile services (GMS/HMS)
  /// Returns a tuple with boolean values indicating presence of
  /// `Google Mobile Services (GMS)` and `Huawei Mobile Services (HMS)`.
  static Future<({bool gms, bool hms})> _getAndroidMobileServices() async {
    if (defaultTargetPlatform != .android) return (gms: false, hms: false);
    try {
      final result = await _channel.invokeMapMethod<String, bool>('getMobileServices');
      return (gms: result?['gms'] ?? false, hms: result?['hms'] ?? false);
    } on PlatformException catch (e, s) {
      l.e('Failed to get mobile services: $e', s);
      return (gms: false, hms: false);
    } on Object catch (e, s) {
      l.e('Unexpected error while getting mobile services: $e', s);
      return (gms: false, hms: false);
    }
  }
}
