/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 29 July 2026
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';

void main() => group('UIPieChart -', () {
  test('formats sub-threshold values as zero', () {
    expect(PieChartSegment.formatDuration(const Duration(microseconds: 999)), '0 ms');
    expect(PieChartSegment.formatPercentage(0.09), '0.0%');
  });

  testWidgets('toggles an expanded donut segment and dismisses its tooltip from the center', (tester) async {
    var selectedIndex = -1;
    await tester.pumpWidget(
      MaterialApp(
        theme: UIThemeData.light(),
        home: Center(
          child: SizedBox.square(
            dimension: 200,
            child: UIPieChart(
              hasAnimation: false,
              innerRadiusFraction: 0.4,
              segments: const [
                PieChartSegment(name: 'First', color: '#ff0000', percent: 50),
                PieChartSegment(name: 'Second', color: '#0000ff', percent: 50),
              ],
              wholeAmount: 100,
              onTap: (index) => selectedIndex = index,
              segmentTooltipBuilder: (context, segment) => Material(child: Text('Tooltip ${segment.name}')),
            ),
          ),
        ),
      ),
    );

    final topLeft = tester.getTopLeft(find.byType(UIPieChart));
    await tester.tapAt(topLeft + const Offset(170, 100));
    await tester.pump();

    expect(selectedIndex, 0);
    expect(find.text('Tooltip First'), findsOneWidget);

    await tester.tapAt(topLeft + const Offset(170, 100));
    await tester.pump();

    expect(find.text('Tooltip First'), findsNothing);

    await tester.tapAt(topLeft + const Offset(170, 100));
    await tester.pump();

    expect(find.text('Tooltip First'), findsOneWidget);

    await tester.tapAt(topLeft + const Offset(100, 100));
    await tester.pump();

    expect(find.text('Tooltip First'), findsNothing);
  });

  testWidgets('keeps legacy geometry tappable', (tester) async {
    var selectedIndex = -1;
    await tester.pumpWidget(
      MaterialApp(
        theme: UIThemeData.light(),
        home: Center(
          child: SizedBox.square(
            dimension: 200,
            child: UIPieChart(
              hasAnimation: false,
              segments: const [PieChartSegment(name: 'Whole', color: '#ff0000', percent: 100)],
              wholeAmount: 100,
              onTap: (index) => selectedIndex = index,
            ),
          ),
        ),
      ),
    );

    final topLeft = tester.getTopLeft(find.byType(UIPieChart));
    await tester.tapAt(topLeft + const Offset(175, 100));
    await tester.pump();

    expect(selectedIndex, 0);
  });
});
