/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 */

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show Listenable, ValueListenable, ValueNotifier;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

/// Stable identifier associated with a pie chart segment.
typedef PieChartSegmentID = int;

/// State for the [UIPieChart] widget.
typedef _PieChartSelection = ({int index, Offset? tooltipAnchor});

/// Builds a label displayed inside a sufficiently large pie chart segment.
typedef PieChartSegmentLabelBuilder = PieChartSegmentLabel? Function(PieChartSegment segment);

/// Builds content displayed after the user taps a pie chart segment.
typedef PieChartSegmentTooltipBuilder = Widget Function(BuildContext context, PieChartSegment segment);

/// Arc information for a pie chart segment, including its index,
/// the segment data, and the start and sweep angles in radians.
typedef _PieChartSegmentArc = ({int index, PieChartSegment segment, double startAngle, double sweepAngle});

/// Text displayed inside a pie chart segment.
@immutable
final class PieChartSegmentLabel {
  /// Creates a two-line segment label.
  const PieChartSegmentLabel({required this.title, required this.value});

  /// The primary segment description.
  final String title;

  /// The secondary segment value.
  final String value;
}

/// Describes one value rendered by [UIPieChart].
///
/// [color] accepts the hexadecimal notation supported by [_colorFromHex].
/// [percent] is expressed on a `0` to `100` scale.
@immutable
class PieChartSegment {
  /// Creates a segment with optional backend-derived values.
  const PieChartSegment({this.categoryID, this.price, this.name, this.color, this.percent});

  /// Creates the compatibility empty value used by existing callers.
  @literal
  const PieChartSegment.empty() : name = '', color = '', price = 0, percent = 0, categoryID = 0;

  /// Parses a segment from a JSON object.
  ///
  /// Numeric fields accept integers, doubles, or numeric strings. Unsupported
  /// value types throw [ArgumentError].
  factory PieChartSegment.fromJson(Map<String, Object?> map) => PieChartSegment(
    categoryID: switch (map['categoryID'] ?? map['category_id']) {
      null => null,
      int vint => vint,
      double vdouble => vdouble.toInt(),
      String vstring when vstring.isNotEmpty => int.tryParse(vstring),
      _ => throw ArgumentError.value(map['categoryID'], 'categoryID', 'Invalid categoryID value: ${map['categoryID']}'),
    },
    price: switch (map['price']) {
      null => null,
      int vint => vint,
      double vdouble => vdouble.toInt(),
      String vstring when vstring.isNotEmpty => int.tryParse(vstring),
      _ => throw ArgumentError.value(map['price'], 'price', 'Invalid price value: ${map['price']}'),
    },
    name: map['name']?.toString(),
    color: map['color']?.toString(),
    percent: switch (map['percent']) {
      null => null,
      double vdouble => vdouble,
      int vint => vint.toDouble(),
      String vstring when vstring.isNotEmpty => double.tryParse(vstring),
      _ => throw ArgumentError.value(map['percent'], 'percent', 'Invalid percent value: ${map['percent']}'),
    },
  );

  /// Optional owning category identifier.
  final PieChartSegmentID? categoryID;

  /// Optional amount represented by this segment.
  final int? price;

  /// User-facing segment label.
  final String? name;

  /// Hexadecimal segment color.
  final String? color;

  /// Portion of the chart on a `0` to `100` scale.
  final double? percent;

  /// Formats a [Duration] into a human-readable string.
  static String formatDuration(Duration duration) {
    final microseconds = duration.inMicroseconds;
    if (microseconds < Duration.microsecondsPerMillisecond) return '0 ms';
    if (microseconds < Duration.microsecondsPerSecond) return '${duration.inMilliseconds} ms';
    return '${(microseconds / Duration.microsecondsPerSecond).toStringAsFixed(2)} s';
  }

  /// Formats a percentage value into a human-readable string.
  static String formatPercentage(double percentage) {
    if (percentage < 0.1) return '0.0%';
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Returns a segment with the supplied non-null fields replaced.
  PieChartSegment copyWith({PieChartSegmentID? categoryID, int? price, String? name, String? color, double? percent}) =>
      PieChartSegment(
        categoryID: categoryID ?? this.categoryID,
        price: price ?? this.price,
        name: name ?? this.name,
        color: color ?? this.color,
        percent: percent ?? this.percent,
      );

  /// Serializes this segment into the UI package's JSON-compatible shape.
  Map<String, Object?> toMap() => {
    'categoryID': categoryID,
    'price': price,
    'name': name,
    'color': color,
    'percent': percent,
  };

  @override
  String toString() =>
      'PieChartSegment{'
      'categoryID: $categoryID, '
      'price: $price, '
      'name: $name, '
      'color: $color, '
      'percent: $percent'
      '}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PieChartSegment &&
        other.categoryID == categoryID &&
        other.price == price &&
        other.name == name &&
        other.percent == percent &&
        other.color == color;
  }

  @override
  int get hashCode => categoryID.hashCode ^ price.hashCode ^ name.hashCode ^ percent.hashCode ^ color.hashCode;
}

/// Pie chart segment tooltip widget.
/// Used to display information about a pie chart segment when it is tapped.
class PieChartSegmentTooltip extends StatelessWidget {
  const PieChartSegmentTooltip({required this.segment, super.key});

  /// The segment to display in the tooltip.
  final PieChartSegment segment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = segment.percent ?? 0;
    final foreground = theme.uiTheme.color.onPrimary;
    final duration = Duration(microseconds: segment.price ?? 0);
    return Semantics(
      liveRegion: true,
      label:
          '${segment.name}, ${PieChartSegment.formatDuration(duration)}, ${PieChartSegment.formatPercentage(percentage)}',
      child: DecoratedBox(
        key: const ValueKey<String>('initialization_segment_tooltip'),
        decoration: BoxDecoration(
          color: theme.uiTheme.color.primary,
          borderRadius: .circular(theme.uiTheme.size.corner.regular),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.uiTheme.color.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: .symmetric(
            horizontal: theme.uiTheme.size.offset.small,
            vertical: theme.uiTheme.size.offset.extraExtraSmall,
          ),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: <Widget>[
              Text(
                segment.name ?? '',
                maxLines: 2,
                overflow: .ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: foreground, height: 1.1, fontWeight: .w500),
              ),
              Text(
                '${PieChartSegment.formatDuration(duration)} · ${PieChartSegment.formatPercentage(percentage)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.72),
                  fontWeight: .w400,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// {@template bb_pie_chart}
/// An animated circular pie chart for visualizing parts of a whole.
///
/// Use this to render category-based totals where each segment contributes to a
/// shared amount and empty space should remain visible when the segments do not
/// fill the full circle.
/// {@endtemplate}
class UIPieChart extends StatefulWidget {
  /// {@macro bb_pie_chart}
  const UIPieChart({
    required this.segments,
    required this.wholeAmount,
    this.child,
    this.onTap,
    this.hasAnimation = true,
    this.innerRadiusFraction,
    this.outerPadding = 0,
    this.segmentGap = 2,
    this.minimumLabelPercent = 8,
    this.selectedSegmentOffset = 6,
    this.segmentLabelBuilder,
    this.segmentTooltipBuilder,
    super.key,
  }) : assert(
         innerRadiusFraction == null || (innerRadiusFraction > 0 && innerRadiusFraction < 1),
         'innerRadiusFraction must be null or greater than 0 and less than 1.',
       ),
       assert(outerPadding >= 0, 'outerPadding must be greater than or equal to 0.'),
       assert(segmentGap >= 0, 'segmentGap must be greater than or equal to 0.'),
       assert(minimumLabelPercent >= 0, 'minimumLabelPercent must be greater than or equal to 0.'),
       assert(selectedSegmentOffset >= 0, 'selectedSegmentOffset must be greater than or equal to 0.');

  /// The segments of the pie chart.
  final List<PieChartSegment?> segments;

  /// If true, the widget will have an animation.
  final bool hasAnimation;

  /// The widget displayed in the center of the chart.
  final Widget? child;

  /// Called with the source-list index of a tapped segment.
  final ValueChanged<int>? onTap;

  /// The radial offset applied to the selected segment in logical pixels.
  final double selectedSegmentOffset;

  /// Inner radius relative to the outer radius.
  ///
  /// When null, the chart keeps its legacy compact-ring geometry. Supplying a
  /// value enables the expanded donut geometry.
  final double? innerRadiusFraction;

  /// The minimum segment percentage that can display an internal label.
  final double minimumLabelPercent;

  /// Empty space between the chart bounds and the outer radius.
  final double outerPadding;

  /// The total amount of the whole.
  final double wholeAmount;

  /// Visual gap between neighboring segments in logical pixels.
  final double segmentGap;

  /// Builds optional text displayed inside segments at or above [minimumLabelPercent].
  final PieChartSegmentLabelBuilder? segmentLabelBuilder;

  /// Builds content displayed near a tapped segment until the chart is tapped elsewhere.
  final PieChartSegmentTooltipBuilder? segmentTooltipBuilder;

  @override
  State<UIPieChart> createState() => _UIPieChartState();
}

/// State for the [UIPieChart] widget.
class _UIPieChartState extends State<UIPieChart> with SingleTickerProviderStateMixin {
  final ValueNotifier<ThemeData> _theme = ValueNotifier<ThemeData>(ThemeData());
  late final ValueNotifier<_PieChartSelection?> _selection;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _selection = ValueNotifier<_PieChartSelection?>(null);
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.hasAnimation ? 600 : 0),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(tween: Tween<double>(begin: 0, end: 0), weight: 1),
        TweenSequenceItem<double>(tween: Tween<double>(begin: 0, end: 1), weight: 1.5),
      ]).animate(_controller),
      curve: Curves.decelerate,
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    if (_theme.value != theme) _theme.value = theme;
  }

  @override
  void dispose() {
    _controller.dispose();
    _selection.dispose();
    _theme.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(UIPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selection.value case final selection? when selection.index >= widget.segments.length) {
      _selection.value = null;
    }
  }

  void _handleTap(TapUpDetails details) {
    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox) return;
    final index = _PieChartGeometry.hitTest(
      position: details.localPosition,
      size: renderBox.size,
      segments: widget.segments,
      wholeAmount: widget.wholeAmount,
      innerRadiusFraction: widget.innerRadiusFraction,
      outerPadding: widget.outerPadding,
      segmentGap: widget.segmentGap,
      selectedSegmentIndex: _selection.value?.index,
      selectedSegmentOffset: widget.selectedSegmentOffset,
    );
    if (index == null) {
      if (_selection.value == null) return;
      _selection.value = null;
      return;
    }
    _selection.value = _selection.value?.index == index
        ? null
        : (index: index, tooltipAnchor: widget.segmentTooltipBuilder == null ? null : details.localPosition);
    widget.onTap?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelTextStyle =
        theme.textTheme.bodySmall?.copyWith(
          color: theme.uiTheme.color.onPrimary,
          overflow: .ellipsis,
          fontWeight: .w500,
          fontSize: 11,
          height: 1.1,
        ) ??
        const TextStyle(fontSize: 11, fontWeight: .w500, overflow: .ellipsis);
    return MergeSemantics(
      child: GestureDetector(
        behavior: .translucent,
        onTapUp: _handleTap,
        child: Stack(
          clipBehavior: .none,
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _PieChartPainter(
                  animation: _animation,
                  selection: _selection,
                  theme: _theme,
                  segments: widget.segments,
                  wholeAmount: widget.wholeAmount,
                  innerRadiusFraction: widget.innerRadiusFraction,
                  outerPadding: widget.outerPadding,
                  segmentGap: widget.segmentGap,
                  minimumLabelPercent: widget.minimumLabelPercent,
                  selectedSegmentOffset: widget.selectedSegmentOffset,
                  segmentLabelBuilder: widget.segmentLabelBuilder,
                  labelTitleStyle: labelTextStyle,
                  labelValueStyle: labelTextStyle.copyWith(fontWeight: .w400),
                  textScaler: MediaQuery.textScalerOf(context),
                ),
                child: Align(alignment: Alignment.center, child: widget.child),
              ),
            ),
            Positioned.fill(
              child: ValueListenableBuilder<_PieChartSelection?>(
                valueListenable: _selection,
                builder: (context, selection, child) {
                  final tooltipBuilder = widget.segmentTooltipBuilder;
                  final tooltipAnchor = selection?.tooltipAnchor;
                  if (selection == null || tooltipAnchor == null || tooltipBuilder == null) {
                    return const SizedBox.shrink();
                  }
                  final selectedSegment = widget.segments[selection.index];
                  if (selectedSegment == null) return const SizedBox.shrink();
                  return IgnorePointer(
                    child: CustomSingleChildLayout(
                      delegate: _PieChartTooltipLayoutDelegate(anchor: tooltipAnchor),
                      child: tooltipBuilder(context, selectedSegment),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.animation,
    required this.selection,
    required this.theme,
    required this.segments,
    required this.wholeAmount,
    required this.innerRadiusFraction,
    required this.outerPadding,
    required this.segmentGap,
    required this.minimumLabelPercent,
    required this.selectedSegmentOffset,
    required this.segmentLabelBuilder,
    required this.labelTitleStyle,
    required this.labelValueStyle,
    required this.textScaler,
  }) : super(repaint: Listenable.merge(<Listenable>[animation, selection, theme]));

  static const double _spaceRadians = _wholeRadians / 180;
  static const double _selectedSegmentOpacity = 0.7;
  static const double _wholeRadians = math.pi * 2;

  final ValueListenable<_PieChartSelection?> selection;
  final ValueListenable<ThemeData> theme;
  final Animation<double> animation;
  final List<PieChartSegment?> segments;
  final double wholeAmount;
  final double outerPadding;
  final double segmentGap;
  final double minimumLabelPercent;
  final double selectedSegmentOffset;
  final double? innerRadiusFraction;
  final PieChartSegmentLabelBuilder? segmentLabelBuilder;
  final TextStyle labelTitleStyle;
  final TextStyle labelValueStyle;
  final TextScaler textScaler;

  /// The current value of the animation, ranging from 0.0 to 1.0.
  double get animationValue => animation.value;

  /// The current UI colors derived from the listened theme.
  UIColors get colors => theme.value.uiTheme.color;

  /// The index of the currently selected segment, or null if no segment is selected.
  int? get selectedSegmentIndex => selection.value?.index;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (innerRadiusFraction case final fraction?) {
      _paintExpanded(canvas, Offset.zero, size, fraction);
      return;
    }
    _paintLegacy(canvas, Offset.zero, size);
  }

  void _paintLegacy(Canvas canvas, Offset offset, Size size) {
    // Create two padded reacts to draw arcs in: one for colored arcs and one for inner bg arc.
    const strokeWidth = 13.0;
    final outerRadius = math.min(size.width, size.height) / 1.66;
    final outerRect = Rect.fromCircle(center: size.center(offset), radius: outerRadius - strokeWidth * 3);
    final innerRect = Rect.fromCircle(center: size.center(offset), radius: outerRadius - strokeWidth * 4);

    // Paint each arc with spacing.
    var cumulativeSpace = 0.0;
    var cumulativeTotal = 0.0;

    if (segments.isEmpty) {
      final paint = Paint()..color = colors.secondaryBackground;
      final startAngle = _calculateStartAngle(cumulativeTotal, cumulativeSpace);
      final sweepAngle = _calculateSweepAngle(100, 0);
      canvas.drawArc(outerRect, startAngle, sweepAngle, true, paint);
      cumulativeTotal += 100;
      cumulativeSpace += _spaceRadians;
    } else {
      for (final segment in segments) {
        if (segment case PieChartSegment(:final color?, :final percent?)) {
          final paint = Paint()..color = _colorFromHex(color);
          final startAngle = _calculateStartAngle(cumulativeTotal, cumulativeSpace);
          final sweepAngle = _calculateSweepAngle(percent, 0.035);
          canvas.drawArc(outerRect, startAngle, sweepAngle, true, paint);
          cumulativeTotal += percent;
          cumulativeSpace += _spaceRadians;
        }
      }
    }

    // Paint any remaining space black (e.g. budget amount remaining).
    final remaining = wholeAmount - cumulativeTotal;
    if (remaining > 0) {
      final paint = Paint()..color = colors.primary;
      final startAngle = _calculateStartAngle(cumulativeTotal, _spaceRadians * segments.length);
      final sweepAngle = _calculateSweepAngle(remaining, -_spaceRadians);
      canvas.drawArc(outerRect, startAngle, sweepAngle, true, paint);
    }

    // Paint a smaller inner circle to cover the painted arcs, so they are
    // display as segments.
    final bgPaint = Paint()..color = colors.background;
    canvas.drawArc(innerRect, 0, math.pi * 2, true, bgPaint);
  }

  void _paintExpanded(Canvas canvas, Offset offset, Size size, double fraction) {
    final geometry = _PieChartGeometry.expanded(
      size: size,
      segments: segments,
      wholeAmount: wholeAmount,
      innerRadiusFraction: fraction,
      outerPadding: outerPadding,
      segmentGap: segmentGap,
    );
    if (geometry.outerRadius <= 0) return;

    final center = geometry.center + offset;
    final emptyColor = colors.secondaryBackground;
    canvas.drawCircle(center, geometry.outerRadius, Paint()..color = segments.isEmpty ? emptyColor : colors.background);

    for (final arc in geometry.arcs) {
      if (arc.index == selectedSegmentIndex) continue;
      final color = switch (arc.segment.color) {
        String color => _colorFromHex(color),
        null => emptyColor,
      };
      canvas.drawPath(
        geometry.segmentPath(arc: arc, center: center, animationValue: animationValue),
        Paint()..color = color,
      );
    }

    if (geometry.remainingSweep > 0) {
      canvas.drawPath(
        geometry.ringPath(
          center: center,
          startAngle: geometry.remainingStartAngle,
          sweepAngle: geometry.remainingSweep * animationValue,
        ),
        Paint()..color = colors.primary,
      );
    }

    if (geometry.arcForIndex(selectedSegmentIndex) case final selectedArc?) {
      final translation = geometry.selectionTranslation(selectedArc, selectedSegmentOffset);
      final selectedPath = geometry.segmentPath(
        arc: selectedArc,
        center: center + translation,
        animationValue: animationValue,
      );
      if (animationValue >= 0.95 && selectedSegmentOffset > 0) {
        canvas.drawShadow(selectedPath, colors.primary.withValues(alpha: 0.28), 5, false);
      }
      final selectedColor = switch (selectedArc.segment.color) {
        String color => _colorFromHex(color),
        null => emptyColor,
      };
      canvas.drawPath(selectedPath, Paint()..color = selectedColor.withValues(alpha: _selectedSegmentOpacity));
    }

    if (animationValue >= 0.95 && segmentLabelBuilder != null) {
      _paintExpandedLabels(canvas, center, geometry);
    }
  }

  void _paintExpandedLabels(Canvas canvas, Offset center, _PieChartGeometry geometry) {
    final ringWidth = geometry.outerRadius - geometry.innerRadius;
    for (final arc in geometry.arcs) {
      final percent = wholeAmount <= 0 ? 0.0 : (arc.segment.percent ?? 0) / wholeAmount * 100;
      if (percent < minimumLabelPercent) continue;
      final label = segmentLabelBuilder?.call(arc.segment);
      if (label == null) continue;

      final translation = arc.index == selectedSegmentIndex
          ? geometry.selectionTranslation(arc, selectedSegmentOffset)
          : Offset.zero;
      final radius = geometry.innerRadius + ringWidth * 0.52;
      final angle = arc.startAngle + arc.sweepAngle / 2;
      final labelCenter = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius) + translation;
      final maximumWidth = math.min(ringWidth * 1.25, geometry.outerRadius * arc.sweepAngle * 0.68);
      if (maximumWidth < 40) continue;

      final segmentColor = switch (arc.segment.color) {
        String color => _colorFromHex(color),
        null => colors.background.withValues(alpha: 0),
      };
      final textColor = _contrastingTextColor(segmentColor);
      final titlePainter = TextPainter(
        text: TextSpan(
          text: label.title,
          style: labelTitleStyle.copyWith(color: textColor, height: 1.1),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        textScaler: textScaler,
        ellipsis: '…',
        maxLines: 1,
      )..layout(maxWidth: maximumWidth);
      final valuePainter = TextPainter(
        text: TextSpan(
          text: label.value,
          style: labelValueStyle.copyWith(color: textColor, height: 1.1),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        textScaler: textScaler,
        maxLines: 1,
      )..layout(maxWidth: maximumWidth);
      final totalHeight = titlePainter.height + valuePainter.height + 2;
      final segmentPath = geometry.segmentPath(arc: arc, center: center + translation, animationValue: 1);
      final labelWidth = _calculateLabelWidth(
        center: labelCenter,
        height: totalHeight,
        maximumWidth: maximumWidth,
        segmentPath: segmentPath,
      );
      if (labelWidth < 40) continue;

      titlePainter.layout(maxWidth: labelWidth);
      valuePainter.layout(maxWidth: labelWidth);
      canvas
        ..save()
        ..clipPath(segmentPath);
      titlePainter.paint(canvas, Offset(labelCenter.dx - titlePainter.width / 2, labelCenter.dy - totalHeight / 2));
      valuePainter.paint(
        canvas,
        Offset(labelCenter.dx - valuePainter.width / 2, labelCenter.dy - totalHeight / 2 + titlePainter.height + 2),
      );
      canvas.restore();
    }
  }

  double _calculateLabelWidth({
    required Offset center,
    required double height,
    required double maximumWidth,
    required Path segmentPath,
  }) {
    const horizontalSamples = 5;
    const verticalSamples = 3;
    const safetyInset = 2.0;
    const searchIterations = 12;

    bool fits(double width) {
      final halfWidth = width / 2 + safetyInset;
      final halfHeight = height / 2 + safetyInset;
      for (var x = 0; x < horizontalSamples; x++) {
        final dx = -halfWidth + halfWidth * 2 * x / (horizontalSamples - 1);
        for (var y = 0; y < verticalSamples; y++) {
          final dy = -halfHeight + halfHeight * 2 * y / (verticalSamples - 1);
          if (!segmentPath.contains(center + Offset(dx, dy))) return false;
        }
      }
      return true;
    }

    if (!fits(0)) return 0;

    var minimumWidth = 0.0;
    var maximumFittingWidth = maximumWidth;
    for (var iteration = 0; iteration < searchIterations; iteration++) {
      final width = (minimumWidth + maximumFittingWidth) / 2;
      if (fits(width)) {
        minimumWidth = width;
      } else {
        maximumFittingWidth = width;
      }
    }
    return minimumWidth;
  }

  double _calculateAngle(double amount, double offset) {
    final wholeMinusSpacesRadians = _wholeRadians - (segments.length * _spaceRadians);
    return animationValue * (amount / wholeAmount * wholeMinusSpacesRadians + offset);
  }

  double _calculateStartAngle(double total, double offset) => _calculateAngle(total, offset) - math.pi / 2;

  double _calculateSweepAngle(double total, double offset) => _calculateAngle(total, offset);

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      segments != oldDelegate.segments ||
      wholeAmount != oldDelegate.wholeAmount ||
      innerRadiusFraction != oldDelegate.innerRadiusFraction ||
      outerPadding != oldDelegate.outerPadding ||
      segmentGap != oldDelegate.segmentGap ||
      minimumLabelPercent != oldDelegate.minimumLabelPercent ||
      selectedSegmentOffset != oldDelegate.selectedSegmentOffset ||
      segmentLabelBuilder != oldDelegate.segmentLabelBuilder ||
      labelTitleStyle != oldDelegate.labelTitleStyle ||
      labelValueStyle != oldDelegate.labelValueStyle ||
      textScaler != oldDelegate.textScaler;
}

final class _PieChartGeometry {
  const _PieChartGeometry({
    required this.arcs,
    required this.center,
    required this.outerRadius,
    required this.innerRadius,
    required this.remainingSweep,
    required this.remainingStartAngle,
  });

  /// Creates a [_PieChartGeometry] instance for the expanded donut geometry.
  factory _PieChartGeometry.expanded({
    required List<PieChartSegment?> segments,
    required double innerRadiusFraction,
    required double outerPadding,
    required double wholeAmount,
    required double segmentGap,
    required Size size,
  }) {
    final outerRadius = math.max(0.0, math.min(size.width, size.height) / 2 - outerPadding);
    final innerRadius = outerRadius * innerRadiusFraction;
    final nonNullSegments = segments.whereType<PieChartSegment>().toList(growable: false);
    final gapRadians = outerRadius <= 0 || nonNullSegments.isEmpty
        ? 0.0
        : math.min(segmentGap / outerRadius, wholeRadians / nonNullSegments.length * 0.8);
    final availableRadians = math.max(0.0, wholeRadians - gapRadians * nonNullSegments.length);
    final arcs = <_PieChartSegmentArc>[];
    var cursor = -math.pi / 2 + gapRadians / 2;
    var consumed = 0.0;
    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      if (segment == null) continue;
      final amount = math.max(0.0, segment.percent ?? 0);
      final sweepAngle = wholeAmount <= 0 ? 0.0 : availableRadians * amount / wholeAmount;
      if (sweepAngle > 0) {
        arcs.add((index: index, segment: segment, startAngle: cursor, sweepAngle: sweepAngle));
      }
      cursor += sweepAngle + gapRadians;
      consumed += amount;
    }
    final remainingAmount = math.max(0.0, wholeAmount - consumed);
    final remainingSweep = wholeAmount <= 0 ? 0.0 : availableRadians * remainingAmount / wholeAmount;
    return _PieChartGeometry(
      arcs: List<_PieChartSegmentArc>.unmodifiable(arcs),
      center: size.center(Offset.zero),
      remainingSweep: remainingSweep,
      remainingStartAngle: cursor,
      outerRadius: outerRadius,
      innerRadius: innerRadius,
    );
  }

  /// Creates a [_PieChartGeometry] instance for the legacy compact-ring geometry.
  factory _PieChartGeometry.legacy({
    required List<PieChartSegment?> segments,
    required double wholeAmount,
    required Size size,
  }) {
    const strokeWidth = 13.0;
    final baseRadius = math.min(size.width, size.height) / 1.66;
    final outerRadius = math.max(0.0, baseRadius - strokeWidth * 3);
    final innerRadius = math.max(0.0, baseRadius - strokeWidth * 4);
    const gapRadians = wholeRadians / 180;
    final availableRadians = math.max(0.0, wholeRadians - segments.length * gapRadians);
    final arcs = <_PieChartSegmentArc>[];
    var cumulativeAmount = 0.0;
    var cumulativeGap = 0.0;
    for (var index = 0; index < segments.length; index++) {
      final segment = segments[index];
      if (segment == null) continue;
      final amount = math.max(0.0, segment.percent ?? 0);
      final startAngle = wholeAmount <= 0
          ? -math.pi / 2
          : cumulativeAmount / wholeAmount * availableRadians + cumulativeGap - math.pi / 2;
      final sweepAngle = wholeAmount <= 0 ? 0.0 : amount / wholeAmount * availableRadians + 0.035;
      if (sweepAngle > 0) {
        arcs.add((index: index, segment: segment, startAngle: startAngle, sweepAngle: sweepAngle));
      }
      cumulativeAmount += amount;
      cumulativeGap += gapRadians;
    }
    return _PieChartGeometry(
      arcs: List<_PieChartSegmentArc>.unmodifiable(arcs),
      center: size.center(Offset.zero),
      outerRadius: outerRadius,
      innerRadius: innerRadius,
      remainingStartAngle: 0,
      remainingSweep: 0,
    );
  }

  final List<_PieChartSegmentArc> arcs;
  final double remainingStartAngle;
  final double remainingSweep;
  final double innerRadius;
  final double outerRadius;
  final Offset center;

  static const double wholeRadians = math.pi * 2;

  _PieChartSegmentArc? arcForIndex(int? index) {
    if (index == null) return null;
    for (final arc in arcs) {
      if (arc.index == index) return arc;
    }
    return null;
  }

  /// Calculates the translation offset for a selected segment based on its arc and the specified distance.
  Offset selectionTranslation(_PieChartSegmentArc arc, double distance) {
    final angle = arc.startAngle + arc.sweepAngle / 2;
    return Offset(math.cos(angle) * distance, math.sin(angle) * distance);
  }

  /// Generates a path for a pie chart segment based on the provided arc, center, and animation value.
  Path segmentPath({required _PieChartSegmentArc arc, required Offset center, required double animationValue}) =>
      ringPath(center: center, startAngle: arc.startAngle, sweepAngle: arc.sweepAngle * animationValue);

  /// Generates a path for a ring segment based on the provided center, start angle, and sweep angle.
  Path ringPath({required Offset center, required double startAngle, required double sweepAngle}) {
    if (sweepAngle <= 0) return Path();
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    return Path()
      ..arcTo(outerRect, startAngle, sweepAngle, true)
      ..arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false)
      ..close();
  }

  /// Performs a hit test to determine which pie chart segment, if any,
  /// was tapped based on the provided position and chart geometry.
  static int? hitTest({
    required Offset position,
    required Size size,
    required List<PieChartSegment?> segments,
    required double wholeAmount,
    required double? innerRadiusFraction,
    required double outerPadding,
    required double segmentGap,
    required int? selectedSegmentIndex,
    required double selectedSegmentOffset,
  }) {
    final geometry = innerRadiusFraction == null
        ? _PieChartGeometry.legacy(size: size, segments: segments, wholeAmount: wholeAmount)
        : _PieChartGeometry.expanded(
            size: size,
            segments: segments,
            wholeAmount: wholeAmount,
            innerRadiusFraction: innerRadiusFraction,
            outerPadding: outerPadding,
            segmentGap: segmentGap,
          );
    final sortedArcs = <_PieChartSegmentArc>[
      ?geometry.arcForIndex(selectedSegmentIndex),
      ...geometry.arcs.where((arc) => arc.index != selectedSegmentIndex),
    ];
    final effectiveSelectedSegmentOffset = innerRadiusFraction == null ? 0.0 : selectedSegmentOffset;
    for (final arc in sortedArcs) {
      final translation = arc.index == selectedSegmentIndex
          ? geometry.selectionTranslation(arc, effectiveSelectedSegmentOffset)
          : Offset.zero;
      final delta = position - geometry.center - translation;
      final distance = delta.distance;
      if (distance < geometry.innerRadius || distance > geometry.outerRadius) continue;
      if (_containsAngle(math.atan2(delta.dy, delta.dx), arc.startAngle, arc.sweepAngle)) return arc.index;
    }
    return null;
  }

  /// Normalizes an angle to the range [0, 2π).
  static bool _containsAngle(double angle, double startAngle, double sweepAngle) {
    final normalizedAngle = _normalizeAngle(angle);
    final normalizedStart = _normalizeAngle(startAngle);
    final normalizedEnd = normalizedStart + sweepAngle;
    return normalizedEnd <= wholeRadians
        ? normalizedAngle >= normalizedStart && normalizedAngle <= normalizedEnd
        : normalizedAngle >= normalizedStart || normalizedAngle <= normalizedEnd - wholeRadians;
  }

  /// Normalizes an angle to the range [0, 2π).
  static double _normalizeAngle(double angle) => (angle % wholeRadians + wholeRadians) % wholeRadians;
}

final class _PieChartTooltipLayoutDelegate extends SingleChildLayoutDelegate {
  const _PieChartTooltipLayoutDelegate({required this.anchor});

  /// The anchor point around which the tooltip should be positioned.
  final Offset anchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().copyWith(maxWidth: constraints.maxWidth * 0.72, maxHeight: constraints.maxHeight * 0.5);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final maxX = math.max(0.0, size.width - childSize.width);
    final maxY = math.max(0.0, size.height - childSize.height);
    final x = (anchor.dx - childSize.width / 2).clamp(0.0, maxX);
    var y = anchor.dy - childSize.height - 12;
    if (y < 0) y = anchor.dy + 12;
    return Offset(x, y.clamp(0.0, maxY));
  }

  @override
  bool shouldRelayout(_PieChartTooltipLayoutDelegate oldDelegate) => oldDelegate.anchor != anchor;
}

Color _colorFromHex(String value) {
  final hex = value.replaceFirst('#', '');
  return Color(int.parse(hex.length == 6 ? 'ff$hex' : hex, radix: 16));
}

Color _contrastingTextColor(Color color) => color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
