import 'dart:async';

import 'package:flutter_template_name/src/common/util/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group('Analytics consent -', () {
  test('blocks collection until restored consent and after opt-out', () async {
    final tracker = _Tracker();
    final analytics = Analytics.forTesting(trackers: [tracker]);
    await analytics.logEvent('test', 'before_restore');
    expect(tracker.events, isEmpty);
    await analytics.setConsent(true);
    await analytics.logEvent('test', 'enabled');
    await analytics.setConsent(false);
    await analytics.logEvent('test', 'disabled');
    await analytics.logPageView('disabled');
    await analytics.setUserProperty(name: 'disabled', value: 'value');
    expect(tracker.events, ['enabled']);
    expect(tracker.consents, [true, false]);
  });

  test('does not restore the previous account identity after an opt-out', () async {
    final tracker = _Tracker();
    final analytics = Analytics.forTesting(trackers: [tracker]);
    await analytics.setConsent(true);
    await analytics.setUserID('first');
    await analytics.setConsent(false);
    expect(tracker.userID, isNull);
    await analytics.setUserID('second');
    expect(tracker.userID, isNull);
    await analytics.setConsent(true);
    expect(tracker.userID, 'second');
  });

  test('serializes provider updates and drops an event when consent is revoked while enabling', () async {
    final tracker = _Tracker()..pendingConsent = Completer<void>();
    final analytics = Analytics.forTesting(trackers: [tracker]);
    final enable = analytics.setConsent(true);
    final event = analytics.logEvent('test', 'pending');
    await Future<void>.delayed(Duration.zero);
    final disable = analytics.setConsent(false);
    tracker.pendingConsent!.complete();
    await Future.wait([enable, event, disable]);
    expect(tracker.consents, [true, false]);
    expect(tracker.events, isEmpty);
  });
});

class _Tracker implements AnalyticsTracker {
  final List<String> events = [];
  final List<bool> consents = [];
  Completer<void>? pendingConsent;
  String? userID;
  @override
  String get name => 'test';
  @override
  Future<void> setConsent(bool consent) async {
    consents.add(consent);
    await pendingConsent?.future;
  }

  @override
  Future<void> logEvent(String category, String event, {Map<String, String>? parameters}) async => events.add(event);
  @override
  Future<void> logPageView(String page, {Map<String, String>? parameters}) async => events.add(page);
  @override
  Future<void> setUserID(String? userID) async => this.userID = userID;
  @override
  Future<void> setUserProperty({required String name, required String? value}) async => events.add(name);
}
