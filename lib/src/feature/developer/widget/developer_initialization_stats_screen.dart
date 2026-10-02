import 'package:flutter_template_name/src/common/localization/localization.dart';
/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 29 July 2026
 */

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/widget/common_back_button.dart';
import 'package:flutter_template_name/src/feature/initialization/model/initialization_stats.dart';
import 'package:ui/ui.dart';

/// {@template developer_initialization_stats_screen}
/// Displays initialization timings collected during the current app launch.
/// {@endtemplate}
class DeveloperInitializationStatsScreen extends StatelessWidget {
  /// Creates the initialization statistics screen.
  const DeveloperInitializationStatsScreen({this.stats, super.key});

  /// An optional snapshot override used by previews and tests.
  final InitializationStats? stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = Localization.of(context);
    final effectiveStats = stats ?? Dependencies.of(context).initializationStats;
    return Scaffold(
      backgroundColor: theme.uiTheme.color.secondaryBackground,
      appBar: AppBar(
        clipBehavior: .none,
        title: Text(l10n.developerInitializationStatsTitle),
        leading: const CommonBackButton(),
        backgroundColor: theme.uiTheme.color.secondaryBackground,
      ),
      body: effectiveStats.steps.isEmpty
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.developerInitializationStatsEmptyTitle),
                    Text(l10n.developerInitializationStatsEmptyDescription, textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : _InitializationStatsContent(stats: effectiveStats),
    );
  }
}

class _InitializationStatsContent extends StatelessWidget {
  const _InitializationStatsContent({required this.stats});

  final InitializationStats stats;

  static Color _heatMapColor(Duration duration, int longestMicroseconds) {
    final fraction = longestMicroseconds <= 0 ? 0.0 : duration.inMicroseconds / longestMicroseconds;
    return HSVColor.fromAHSV(1, 200 * (1 - fraction.clamp(0.0, 1.0)), 0.78, 0.92).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedSteps = stats.stepsByDuration;
    final longestMicroseconds = sortedSteps.first.duration.inMicroseconds;
    final colors = <InitializationStepTiming, Color>{
      for (final step in sortedSteps) step: _heatMapColor(step.duration, longestMicroseconds),
    };
    final segments = sortedSteps
        .where((step) => step.duration.inMicroseconds >= Duration.microsecondsPerMillisecond)
        .map<PieChartSegment>(
          (step) => PieChartSegment(
            color: '#${(colors[step] ?? theme.uiTheme.color.accent).toARGB32().toRadixString(16).padLeft(8, '0')}',
            price: step.duration.inMicroseconds,
            percent: stats.percentageOf(step),
            categoryID: step.index,
            name: step.name,
          ),
        )
        .toList(growable: false);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: .fromLTRB(
              theme.uiTheme.size.offset.regular,
              theme.uiTheme.size.offset.medium,
              theme.uiTheme.size.offset.regular,
              theme.uiTheme.size.offset.small,
            ),
            child: _InitializationChart(stats: stats, segments: segments),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: .fromLTRB(
              theme.uiTheme.size.offset.regular,
              theme.uiTheme.size.offset.small,
              theme.uiTheme.size.offset.regular,
              theme.uiTheme.size.offset.medium,
            ),
            child: Text(
              Localization.of(context).developerInitializationHeatMapDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ),
        SliverPadding(
          padding: .fromLTRB(
            theme.uiTheme.size.offset.regular,
            0,
            theme.uiTheme.size.offset.regular,
            theme.uiTheme.size.offset.medium,
          ),
          sliver: SliverList.builder(
            itemCount: sortedSteps.length + 1,
            itemBuilder: (context, index) {
              if (index == sortedSteps.length) {
                return _InitializationStatsFooter(stats: stats);
              }
              final step = sortedSteps[index];
              return _InitializationStepTile(
                color: colors[step]!,
                isFirst: index == 0,
                name: step.name,
                duration: step.duration,
                percentage: stats.percentageOf(step),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InitializationChart extends StatelessWidget {
  const _InitializationChart({required this.stats, required this.segments});

  final InitializationStats stats;
  final List<PieChartSegment> segments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleWholeAmount = segments.fold<double>(0, (total, segment) => total + (segment.percent ?? 0));
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = math.min(constraints.maxWidth, 420.0);
        return Center(
          child: SizedBox.square(
            dimension: dimension,
            child: UIPieChart(
              innerRadiusFraction: 0.4,
              minimumLabelPercent: 8,
              segmentGap: 2,
              segments: segments,
              wholeAmount: visibleWholeAmount,
              segmentLabelBuilder: (segment) => PieChartSegmentLabel(
                title: segment.name ?? '',
                value: PieChartSegment.formatDuration(Duration(microseconds: segment.price ?? 0)),
              ),
              segmentTooltipBuilder: (context, segment) => PieChartSegmentTooltip(segment: segment),
              child: Column(
                mainAxisSize: .min,
                children: [
                  Text(PieChartSegment.formatDuration(stats.totalDuration), style: theme.textTheme.displaySmall),
                  Text(Localization.of(context).developerTotalLabel, style: theme.textTheme.labelSmall),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InitializationStepTile extends StatelessWidget {
  const _InitializationStepTile({
    required this.isFirst,
    required this.name,
    required this.color,
    required this.percentage,
    required this.duration,
  });

  final bool isFirst;
  final String name;
  final Color color;
  final double percentage;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.uiTheme.color.onSecondaryBackground,
        borderRadius: isFirst ? .vertical(top: .circular(theme.uiTheme.size.corner.medium)) : .zero,
      ),
      child: Padding(
        padding: .symmetric(horizontal: theme.uiTheme.size.offset.regular, vertical: theme.uiTheme.size.offset.small),
        child: Row(
          spacing: theme.uiTheme.size.offset.small,
          children: [
            SizedBox.square(
              dimension: theme.uiTheme.size.icon.extraExtraSmall,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: .circle),
              ),
            ),
            Expanded(
              child: Text(name, maxLines: 1, overflow: .ellipsis, style: theme.textTheme.bodyMedium),
            ),
            Text(PieChartSegment.formatDuration(duration), style: theme.textTheme.bodyMedium),
            SizedBox(
              width: 52,
              child: Text(
                PieChartSegment.formatPercentage(percentage),
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.uiTheme.color.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitializationStatsFooter extends StatelessWidget {
  const _InitializationStatsFooter({required this.stats});

  final InitializationStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.uiTheme.color.onSecondaryBackground,
        borderRadius: .vertical(bottom: Radius.circular(theme.uiTheme.size.corner.medium)),
      ),
      child: Padding(
        padding: .all(theme.uiTheme.size.offset.regular),
        child: Row(
          children: [
            Expanded(
              child: Text(
                Localization.of(context).developerInitializationStatsTotalMessageOf(stats.steps.length),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              PieChartSegment.formatDuration(stats.totalDuration),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
