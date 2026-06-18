// ignore_for_file: require_trailing_commas, depend_on_referenced_packages, prefer_mixin, avoid-top-level-members-in-tests, prefer-static-class, return_of_invalid_type
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

typedef Callback = void Function(MethodCall call);

const String kTestString = 'Hello World';

final MockFirebaseMessaging kMockMessagingPlatform = MockFirebaseMessaging();

Future<T> neverEndingFuture<T>() async {
  // ignore: literal_only_boolean_expressions
  while (true) {
    await Future<void>.delayed(const Duration(minutes: 5));
  }
}

void setupFirebaseMessagingMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  // Mock Platform Interface Methods
  when(kMockMessagingPlatform.delegateFor(app: anyNamed('app'))).thenReturn(kMockMessagingPlatform);

  when(
    kMockMessagingPlatform.setInitialValues(isAutoInitEnabled: anyNamed('isAutoInitEnabled')),
  ).thenReturn(kMockMessagingPlatform);
}

// Platform Interface Mock Classes

// FirebaseMessagingPlatform Mock
class MockFirebaseMessaging extends Mock with MockPlatformInterfaceMixin implements FirebaseMessagingPlatform {
  MockFirebaseMessaging() {
    TestFirebaseMessagingPlatform();
  }

  // @override
  // bool get isAutoInitEnabled => true;

  @override
  bool get isAutoInitEnabled =>
      super.noSuchMethod(Invocation.getter(#isAutoInitEnabled), returnValue: false, returnValueForMissingStub: false)
          as bool;

  @override
  FirebaseMessagingPlatform delegateFor({FirebaseApp? app}) =>
      super.noSuchMethod(
            Invocation.method(#delegateFor, [], {#app: app}),
            returnValue: TestFirebaseMessagingPlatform(),
            returnValueForMissingStub: TestFirebaseMessagingPlatform(),
          )
          as FirebaseMessagingPlatform;

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) =>
      super.noSuchMethod(
            Invocation.method(#setInitialValues, [], {#isAutoInitEnabled: isAutoInitEnabled}),
            returnValue: TestFirebaseMessagingPlatform(),
            returnValueForMissingStub: TestFirebaseMessagingPlatform(),
          )
          as FirebaseMessagingPlatform;

  @override
  Future<void> deleteToken() =>
      super.noSuchMethod(
            Invocation.method(#deleteToken, []),
            returnValue: Future<void>.value(),
            returnValueForMissingStub: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<String?> getAPNSToken() =>
      super.noSuchMethod(
            Invocation.method(#getAPNSToken, []),
            returnValue: Future<String>.value(''),
            returnValueForMissingStub: Future<String>.value(''),
          )
          as Future<String?>;

  @override
  Future<String> getToken({String? serviceWorkerScriptPath, String? vapidKey}) =>
      super.noSuchMethod(
            Invocation.method(#getToken, [], {#vapidKey: vapidKey}),
            returnValue: Future<String>.value(''),
            returnValueForMissingStub: Future<String>.value(''),
          )
          as Future<String>;

  @override
  Future<void> setAutoInitEnabled(bool? enabled) =>
      super.noSuchMethod(
            Invocation.method(#setAutoInitEnabled, [enabled]),
            returnValue: Future<void>.value(),
            returnValueForMissingStub: Future<void>.value(),
          )
          as Future<void>;

  @override
  Stream<String> get onTokenRefresh =>
      super.noSuchMethod(
            Invocation.getter(#onTokenRefresh),
            returnValue: const Stream<String>.empty(),
            returnValueForMissingStub: const Stream<String>.empty(),
          )
          as Stream<String>;

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool providesAppNotificationSettings = false,
    bool provisional = false,
    bool sound = true,
  }) =>
      super.noSuchMethod(
            Invocation.method(#requestPermission, [], {
              #alert: alert,
              #announcement: announcement,
              #badge: badge,
              #carPlay: carPlay,
              #criticalAlert: criticalAlert,
              #providesAppNotificationSettings: providesAppNotificationSettings, // Новый параметр
              #provisional: provisional,
              #sound: sound,
            }),
            returnValue: neverEndingFuture<NotificationSettings>(),
            returnValueForMissingStub: neverEndingFuture<NotificationSettings>(),
          )
          as Future<NotificationSettings>;

  @override
  Future<void> subscribeToTopic(String? topic) =>
      super.noSuchMethod(
            Invocation.method(#subscribeToTopic, [topic]),
            returnValue: Future<void>.value(),
            returnValueForMissingStub: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<void> unsubscribeFromTopic(String? topic) =>
      super.noSuchMethod(
            Invocation.method(#unsubscribeFromTopic, [topic]),
            returnValue: Future<void>.value(),
            returnValueForMissingStub: Future<void>.value(),
          )
          as Future<void>;
}

class TestFirebaseMessagingPlatform extends FirebaseMessagingPlatform {
  TestFirebaseMessagingPlatform() : super();
}
