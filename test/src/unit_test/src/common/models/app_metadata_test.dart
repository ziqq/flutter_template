/*
 * Date: 18 May 2026
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template_name/src/common/model/app_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

const _appmetadataChannel = MethodChannel('ru.beautybox.twa/app_metadata');
const _deviceinfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');

void main() => group('AppMetadata -', () {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(_appmetadataChannel, (call) async {
        if (call.method != 'getMobileServices') return null;
        return <String, bool>{'gms': true, 'hms': false};
      })
      ..setMockMethodCallHandler(_deviceinfoChannel, (call) async {
        if (call.method != 'getDeviceInfo') return null;
        return <String, Object?>{
          'version': <String, Object?>{
            'baseOS': 'Android',
            'previewSdkInt': 0,
            'securityPatch': '2026-01-01',
            'codename': 'REL',
            'incremental': '1',
            'release': '14',
            'sdkInt': 34,
          },
          'board': 'board',
          'bootloader': 'bootloader',
          'brand': 'brand',
          'device': 'device',
          'display': 'display',
          'fingerprint': 'fingerprint',
          'hardware': 'hardware',
          'host': 'host',
          'id': 'id',
          'manufacturer': 'Samsung',
          'model': 'model',
          'product': 'product',
          'name': 'name',
          'supported32BitAbis': const <String>[],
          'supported64BitAbis': const <String>[],
          'supportedAbis': const <String>[],
          'tags': 'tags',
          'type': 'user',
          'isPhysicalDevice': true,
          'freeDiskSize': 1,
          'totalDiskSize': 2,
          'systemFeatures': const <String>[],
          'isLowRamDevice': false,
          'physicalRamSize': 3,
          'availableRamSize': 4,
        };
      });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(_appmetadataChannel, null)
      ..setMockMethodCallHandler(_deviceinfoChannel, null);
  });

  group('platform -', () {
    test('reads GMS and HMS flags from the platform channel instead of manufacturer', () async {
      final metadata = await AppMetadata.platform();

      expect(metadata.operatingSystemManufacturer, 'Samsung');
      expect(metadata.hasGmsServices, isTrue);
      expect(metadata.hasHmsServices, isFalse);
    });

    test('falls back to false flags when the mobile-services channel fails', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        _appmetadataChannel,
        (_) async => throw PlatformException(code: 'unavailable'),
      );

      final metadata = await AppMetadata.platform();

      expect(metadata.hasGmsServices, isFalse);
      expect(metadata.hasHmsServices, isFalse);
    });
  });
});
