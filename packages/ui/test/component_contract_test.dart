import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() {
  group('UISelect -', () {
    testWidgets('reset, controller replacement and option removal keep caller ownership', (tester) async {
      final first = ValueNotifier<String?>('Design');
      final replacement = ValueNotifier<String?>('Research');
      final form = GlobalKey<FormState>();
      addTearDown(first.dispose);
      addTearDown(replacement.dispose);
      Widget field(ValueNotifier<String?> controller, List<String> items) => Form(
        key: form,
        child: UISelect<String>(
          controller: controller,
          items: items,
          displayStringForOption: (value) => value,
          validator: (value) => value == null ? 'Choose a value' : null,
        ),
      );

      await _pumpUI(tester, field(first, ['Design', 'Research']));
      first.value = 'Research';
      await _pumpUI(tester, field(first, ['Design', 'Research']));
      form.currentState!.reset();
      await tester.pump();
      expect(first.value, 'Design');

      await _pumpUI(tester, field(replacement, ['Design', 'Research']));
      first.value = null;
      await tester.pump();
      expect(find.text('Research'), findsOneWidget);
      await _pumpUI(tester, field(replacement, ['Design']));
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Choose a value'), findsOneWidget);
      expect(replacement.value, 'Research');

      await tester.pumpWidget(const SizedBox.shrink());
      replacement.value = 'Design';
      expect(tester.takeException(), isNull);
    });
  });

  group('UISearchInput -', () {
    testWidgets('clear changes the query once and observes the suffix action', (tester) async {
      final controller = TextEditingController(text: 'query');
      final changes = <String>[];
      var suffixActions = 0;
      addTearDown(controller.dispose);
      await _pumpUI(
        tester,
        UISearchInput(controller: controller, onChanged: changes.add, onSuffixTap: () => suffixActions++),
      );
      await tester.tap(find.byIcon(CupertinoIcons.xmark_circle_fill));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(changes, ['']);
      expect(suffixActions, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.text = 'still caller-owned';
      expect(tester.takeException(), isNull);
    });
  });

  group('UIPasswordInput -', () {
    testWidgets('visibility preserves selection and focus without enabling suggestions', (tester) async {
      final controller = TextEditingController.fromValue(
        const TextEditingValue(text: 'secret', selection: TextSelection(baseOffset: 1, extentOffset: 4)),
      );
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      await _pumpUI(tester, UIPasswordInput(controller: controller, focusNode: focus));
      focus.requestFocus();
      await tester.pump();
      final before = controller.value;
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(controller.value, before);
      expect(focus.hasFocus, isTrue);
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.obscureText, isFalse);
      expect(editable.autocorrect, isFalse);
      expect(editable.enableSuggestions, isFalse);
    });
  });

  group('UILoadingController -', () {
    test('overlapping completion preserves other work and the original error', () async {
      final controller = UILoadingController();
      final first = Completer<int>();
      final second = Completer<int>();
      addTearDown(controller.dispose);
      final firstResult = controller.run(() => first.future, message: 'First');
      final secondResult = controller.run(() => second.future, lazy: true, message: 'Second');
      expect(controller.message, isNull);
      first.complete(1);
      expect(await firstResult, 1);
      expect(controller.isProcessing, isTrue);
      expect(controller.isLazyLoading, isTrue);
      expect(controller.message, 'Second');
      final error = StateError('operation failed');
      final assertion = expectLater(secondResult, throwsA(same(error)));
      second.completeError(error);
      await assertion;
      expect(controller.isProcessing, isFalse);
    });

    test('a late result remains usable after disposal without notifying listeners', () async {
      final controller = UILoadingController();
      final completion = Completer<int>();
      var notifications = 0;
      controller.addListener(() => notifications++);
      final result = controller.run(() => completion.future);
      controller.dispose();
      completion.complete(42);
      expect(await result, 42);
      expect(notifications, 1);
      await expectLater(controller.run(() async => 0), throwsStateError);
    });
  });

  group('UILazyLoadScrollView -', () {
    testWidgets('guards repeated requests and ignores completion after unmount', (tester) async {
      final scroll = ScrollController();
      final pending = Completer<void>();
      var calls = 0;
      addTearDown(scroll.dispose);
      await _pumpUI(
        tester,
        SizedBox(
          height: 300,
          child: UILazyLoadScrollView(
            onLazyLoad: () {
              calls++;
              return pending.future;
            },
            child: ListView.builder(
              controller: scroll,
              itemCount: 20,
              itemExtent: 100,
              itemBuilder: (_, index) => Text('Row $index'),
            ),
          ),
        ),
      );
      scroll.jumpTo(scroll.position.maxScrollExtent - 20);
      await tester.pump();
      scroll.jumpTo(scroll.position.maxScrollExtent);
      await tester.pump();
      expect(calls, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      pending.complete();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('UIShowcaseSequence -', () {
    testWidgets('uses the latest callback without restarting a finished sequence', (tester) async {
      UIShowcaseController? current;
      var firstCalls = 0;
      var latestCalls = 0;
      Widget sequence(VoidCallback onFinish) => UIShowcaseSequence(
        steps: const ['first'],
        onFinish: onFinish,
        child: Builder(
          builder: (context) {
            current = UIShowcaseScope.of(context)..register('first');
            return const Text('Target');
          },
        ),
      );
      await _pumpUI(tester, sequence(() => firstCalls++));
      final original = current;
      await _pumpUI(tester, sequence(() => latestCalls++));
      expect(current, same(original));
      current!.next();
      expect(firstCalls, 0);
      expect(latestCalls, 1);
      await _pumpUI(tester, sequence(() => latestCalls++));
      await tester.pump(const Duration(seconds: 1));
      expect(current!.isRunning, isFalse);
      expect(latestCalls, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('Shimmer -', () {
    testWidgets('retains its State when moving into and out of a shared group', (tester) async {
      final key = GlobalKey();
      Widget shimmer() => Shimmer(key: key, size: const Size(120, 40));
      await _pumpUI(tester, shimmer());
      final original = key.currentState;
      await _pumpUI(tester, UIShimmerGroup(child: shimmer()));
      expect(key.currentState, same(original));
      await _pumpUI(tester, shimmer());
      expect(key.currentState, same(original));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpUI(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: UIThemeData.light(),
    localizationsDelegates: const [UILocalizations.delegate],
    home: Scaffold(body: Center(child: child)),
  ),
);
