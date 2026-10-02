import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ui/ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sheet validates and returns a typed result on the native navigator', (tester) async {
    await _openCategory(tester, 'Sheets');
    await tester.tap(find.text('Open keyboard form'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Save form'));
    await tester.pump();
    expect(find.text('Enter a name'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Native form');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Save form'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Sheet returned: Native form'), findsOneWidget);
  });

  testWidgets('duration cancellation preserves the value and confirmation updates it', (tester) async {
    await _openCategory(tester, 'Pickers');
    await tester.tap(find.byType(UIDateTimePickerRow).last);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CupertinoTimerPicker), findsOneWidget);
    final wheel = find
        .descendant(of: find.byType(CupertinoTimerPicker), matching: find.byType(ListWheelScrollView))
        .last;
    await tester.drag(wheel, const Offset(0, -64));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0 h 45 min'), findsOneWidget);
    await tester.tap(find.byType(UIDateTimePickerRow).last);
    await tester.pump(const Duration(seconds: 1));
    await tester.drag(wheel, const Offset(0, -64));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0 h 45 min'), findsNothing);
    expect(find.byType(CupertinoTimerPicker), findsNothing);
  });

  testWidgets('Android IME leaves the focused field and pinned sheet action visible', (tester) async {
    await _openCategory(tester, 'Sheets');
    await tester.tap(find.text('Open keyboard form'));
    await tester.pump(const Duration(seconds: 1));
    final notes = find.descendant(
      of: find.byWidgetPredicate((widget) => widget is UITextInput && widget.labelText == 'Notes'),
      matching: find.byType(EditableText),
    );
    await tester.tap(notes);
    for (var attempt = 0; attempt < 30 && tester.view.viewInsets.bottom == 0; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.view.viewInsets.bottom, greaterThan(0), reason: 'A real Android IME must be visible.');
    await tester.pump(const Duration(milliseconds: 500));
    final keyboardTop =
        (tester.view.physicalSize.height - tester.view.viewInsets.bottom) / tester.view.devicePixelRatio;
    expect(tester.getRect(find.text('Save form')).bottom, lessThan(keyboardTop));
    expect(tester.getRect(notes).bottom, lessThanOrEqualTo(keyboardTop));
    expect(tester.takeException(), isNull);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 500));
  }, skip: !Platform.isAndroid);
}

Future<void> _openCategory(WidgetTester tester, String title) async {
  themeModeSwitcher.value = ThemeMode.light;
  await tester.pumpWidget(const UIExampleApp());
  await tester.pumpAndSettle();
  final target = find.text(title);
  final categories = find.descendant(
    of: find.byKey(const ValueKey<String>('catalog_category_list')),
    matching: find.byType(Scrollable),
  );
  await tester.scrollUntilVisible(target, 300, scrollable: categories);
  await tester.tap(target);
  await tester.pumpAndSettle();
}
