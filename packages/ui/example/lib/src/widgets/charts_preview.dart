import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

enum _ChartData { regular, empty, single, many }

/// Demonstrates chart selection, tooltips, and representative data shapes.
class UIChartsPreview extends StatefulWidget {
  const UIChartsPreview({super.key});

  @override
  State<UIChartsPreview> createState() => _UIChartsPreviewState();
}

class _UIChartsPreviewState extends State<UIChartsPreview> {
  static const _segmentColors = <String>['#0088FF', '#34C759', '#FF9500', '#AF52DE', '#FF2D55'];

  _ChartData _data = _ChartData.regular;
  double _innerRadius = .55;
  bool _animated = true;
  int? _selected;

  List<PieChartSegment> get _segments {
    final values = switch (_data) {
      _ChartData.regular => <double>[45, 30, 25],
      _ChartData.empty => <double>[],
      _ChartData.single => <double>[100],
      _ChartData.many => List<double>.filled(20, 5),
    };
    return <PieChartSegment>[
      for (var index = 0; index < values.length; index++)
        PieChartSegment(
          categoryID: index,
          name: 'Category ${index + 1}',
          color: _segmentColors[index % _segmentColors.length],
          percent: values[index],
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = _segments;
    return PreviewSection(
      title: 'Charts',
      child: Padding(
        padding: PreviewSection.contentPaddingOf(context),
        child: ComponentPreviewGroup(
          title: 'Parts of a whole',
          description: 'Tap a segment to inspect it. The legend also exposes every value as text.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.uiTheme.size.offset.regular,
            children: <Widget>[
              Wrap(
                spacing: theme.uiTheme.size.offset.small,
                runSpacing: theme.uiTheme.size.offset.small,
                children: <Widget>[
                  for (final data in _ChartData.values)
                    ChoiceChip(
                      selectedColor: theme.uiTheme.color.accent,
                      labelStyle: theme.textTheme.labelLarge?.copyWith(
                        color: _data == data ? theme.uiTheme.color.onAccent : theme.uiTheme.color.text,
                      ),
                      label: Text(data.name),
                      selected: _data == data,
                      onSelected: (_) => setState(() {
                        _data = data;
                        _selected = null;
                      }),
                    ),
                ],
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text('Animate data changes', style: Theme.of(context).textTheme.bodyLarge),
                value: _animated,
                onChanged: (value) => setState(() => _animated = value),
              ),
              Text('Inner radius: ${(_innerRadius * 100).round()}%'),
              Slider(
                value: _innerRadius,
                min: .25,
                max: .75,
                label: '${(_innerRadius * 100).round()}%',
                onChanged: (value) => setState(() => _innerRadius = value),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: UIPieChart(
                      key: ValueKey<_ChartData>(_data),
                      segments: segments,
                      wholeAmount: segments.isEmpty ? 0 : 100,
                      innerRadiusFraction: _innerRadius,
                      hasAnimation: _animated && !MediaQuery.disableAnimationsOf(context),
                      segmentLabelBuilder: (segment) => PieChartSegmentLabel(
                        title: segment.name ?? 'Category',
                        value: '${segment.percent?.round()}%',
                      ),
                      segmentTooltipBuilder: (context, segment) => Material(
                        color: theme.uiTheme.color.surface,
                        borderRadius: UIBorderRadius.small(context),
                        child: Padding(
                          padding: EdgeInsets.all(theme.uiTheme.size.offset.small),
                          child: Text('${segment.name}: ${segment.percent?.round()}%'),
                        ),
                      ),
                      onTap: (index) => setState(() => _selected = index),
                      child: Text(segments.isEmpty ? 'No data' : '100%'),
                    ),
                  ),
                ),
              ),
              Semantics(
                liveRegion: true,
                child: Text(_selected == null ? 'Select a segment' : 'Selected Category ${_selected! + 1}'),
              ),
              for (final segment in segments) Text('${segment.name} — ${segment.percent?.round()}%'),
            ],
          ),
        ),
      ),
    );
  }
}
