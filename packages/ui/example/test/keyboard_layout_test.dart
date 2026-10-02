import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  testWidgets('focused password stays visible when keyboard insets grow', (tester) async {
    tester.view.physicalSize = const Size(420, 912);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const UIExampleApp());
    await tester.tap(find.text('Inputs'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final password = find.descendant(of: find.byType(UIPasswordInput), matching: find.byType(EditableText));
    await tester.ensureVisible(password);
    await tester.tap(password);
    await tester.pump();
    tester.view.viewInsets = const FakeViewPadding(bottom: 340);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getRect(password).bottom, lessThanOrEqualTo(572));
    expect(tester.takeException(), isNull);
  });
}
