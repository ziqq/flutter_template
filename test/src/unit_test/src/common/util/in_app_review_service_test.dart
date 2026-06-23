// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff
// ignore_for_file: unused_local_variable, depend_on_referenced_packages, prefer_mixin, return_of_invalid_type

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/util/in_app_review_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_review_platform_interface/in_app_review_platform_interface.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../../util/test_util.dart';

void main() => group('InAppReviewService -', () {
  late MockSharedPreferencesAsync sharedPreferences;
  late MockInAppReviewPlatform platform;
  late InAppReviewService service;

  final inAppReview = InAppReview.instance;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    platform = MockInAppReviewPlatform();
    InAppReviewPlatform.instance = platform;
    sharedPreferences = MockSharedPreferencesAsync();
    service = InAppReviewService(sharedPreferences: sharedPreferences);
  });
  tearDown(() {});

  final dateMock = DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now());

  group('isSecondTimeOpen() -', () {
    test('should be success', () async {
      when(sharedPreferences.getString(any)).thenAnswer((_) async => dateMock);
      await service.isSecondTimeOpen();
      verify(sharedPreferences.getString('${Config.storageNamespace}.review.open_date'));
    });
    test('should should be success and return `true`', () async {
      when(sharedPreferences.getString(any)).thenAnswer((_) async => dateMock);
      expect(service.isSecondTimeOpen(), completion(isTrue));
    });
    test('should return <false>', () async {
      when(sharedPreferences.getString(any)).thenAnswer((_) async => null);
      expect(service.isSecondTimeOpen(), completion(false));
    });
    test('should catch error and return <false>', () async {
      when(sharedPreferences.getString(any)).thenThrow(MockService.exceptions.api);
      expect(service.isSecondTimeOpen(), completion(isFalse));
    });
  });

  group('showRating() -', () {
    test('should check isAvailable', () async {
      when(platform.isAvailable()).thenAnswer((_) async => true);
      await service.showRating();
      verify(platform.isAvailable());
    });
    test('should call requestReview', () async {
      when(platform.isAvailable()).thenAnswer((_) async => true);
      await service.showRating();
      verify(platform.requestReview());
    });
    test('should call openStoreListing', () async {
      when(platform.isAvailable()).thenAnswer((_) async => false);

      await service.showRating();
      verify(platform.openStoreListing(appStoreId: anyNamed('appStoreId')));
    });
    test('should return <false>', () async {
      final result = await service.showRating();
      expect(result, isFalse);
    });
    test('should return <true>', () async {
      when(platform.isAvailable()).thenAnswer((_) async => true);
      when(platform.requestReview()).thenAnswer((_) => Future.value());

      final result = await service.showRating();
      expect(result, isTrue);
    });
    test('should will set date to storageService', () async {
      when(sharedPreferences.getString(any)).thenAnswer((_) async => '');
      when(platform.isAvailable()).thenAnswer((_) async => true);
      when(platform.requestReview()).thenAnswer((_) => Future.value());

      await service.showRating();
      verify(sharedPreferences.setString(any, any));
    });
  });

  group('openStoreListing() -', () {
    test('should will return true', () async {
      when(platform.openStoreListing(appStoreId: anyNamed('appStoreId'))).thenAnswer((_) async => true);

      final result = await service.openStoreListing();

      expect(result, isTrue);

      verify(
        platform.openStoreListing(appStoreId: anyNamed('appStoreId'), microsoftStoreId: anyNamed('microsoftStoreId')),
      );
    });
    test('should will return false', () async {
      final result = await service.openStoreListing();

      expect(result, isFalse);

      verify(
        platform.openStoreListing(appStoreId: anyNamed('appStoreId'), microsoftStoreId: anyNamed('microsoftStoreId')),
      );
    });
  });
});

class MockInAppReviewPlatform extends Mock with MockPlatformInterfaceMixin implements InAppReviewPlatform {
  @override
  Future<bool> isAvailable() =>
      super.noSuchMethod(Invocation.method(#isAvailable, null), returnValue: Future.value(true));

  @override
  Future<void> requestReview() =>
      super.noSuchMethod(Invocation.method(#requestReview, null), returnValue: Future<void>.value());

  @override
  Future<void> openStoreListing({String? appStoreId, String? microsoftStoreId}) => super.noSuchMethod(
    Invocation.method(#openStoreListing, null, {#appStoreId: appStoreId, #microsoftStoreId: microsoftStoreId}),
    returnValue: Future<void>.value(),
  );
}
