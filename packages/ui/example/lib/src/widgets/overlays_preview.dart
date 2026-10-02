import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

/// Shows anchored menus and a repeatable three-step onboarding sequence.
class UIOverlaysPreview extends StatelessWidget {
  const UIOverlaysPreview({super.key});

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Overlays and onboarding',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Theme.of(context).uiTheme.size.offset.regular,
        children: <Widget>[
          const ComponentPreviewGroup(
            title: 'Anchored menus',
            description:
                'Open a target and scroll the page. The menu follows its anchor and reports flipped placement.',
            child: SizedBox(
              height: 260,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: _FlyoutTarget(label: 'Top left'),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: _FlyoutTarget(label: 'Top right'),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: _FlyoutTarget(label: 'Bottom left'),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _FlyoutTarget(label: 'Bottom right'),
                  ),
                ],
              ),
            ),
          ),
          ComponentPreviewGroup(
            title: 'Guided tour',
            description: 'Tap a highlighted action to advance; Close tour and Escape cancel. Start again replays all three steps.',
            child: FilledButton.tonal(
              onPressed: () =>
                  Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => const _TourScreen())),
              child: const Text('Start three-step tour'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FlyoutTarget extends StatefulWidget {
  const _FlyoutTarget({required this.label});

  final String label;

  @override
  State<_FlyoutTarget> createState() => _FlyoutTargetState();
}

class _FlyoutTargetState extends State<_FlyoutTarget> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => UIFlyout(
    isOpen: _open,
    anchor: const UIFlyoutAnchor(
      anchorAlignment: Alignment.bottomCenter,
      flyoutAlignment: Alignment.topCenter,
      offset: Offset(0, 8),
    ),
    flyoutBuilder: (context, placement) {
      final theme = Theme.of(context);
      final uiTheme = theme.uiTheme;
      final borderRadius = UIBorderRadius.regular(context);
      final pointsUp = !placement.flippedVertically;
      final textStyle = theme.textTheme.labelSmall?.copyWith(color: uiTheme.color.onAccent, height: 1);
      final arrow = ClipPath(
        clipper: _FlyoutArrowClipper(pointsUp: pointsUp),
        child: SizedBox(width: 16, height: 8, child: ColoredBox(color: uiTheme.color.accent)),
      );
      final body = Material(
        color: uiTheme.color.accent,
        borderRadius: borderRadius,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.widthOf(context) - uiTheme.size.offset.small * 2).clamp(0, 260),
          ),
          child: Padding(
            padding: EdgeInsets.all(uiTheme.size.offset.small),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: uiTheme.size.offset.small,
              children: <Widget>[
                Text('Menu: ${widget.label}', style: textStyle),
                Text(
                  'Flipped: horizontal ${placement.flippedHorizontally}, vertical ${placement.flippedVertically}',
                  style: textStyle,
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SizedBox(
                    height: uiTheme.size.button.extraExtraSmall,
                    child: CupertinoButton(
                      onPressed: () => setState(() => _open = false),
                      borderRadius: borderRadius,
                      foregroundColor: uiTheme.color.onAccent,
                      color: uiTheme.color.onAccent.withValues(alpha: .16),
                      padding: EdgeInsets.symmetric(horizontal: uiTheme.size.offset.small),
                      minimumSize: Size.square(uiTheme.size.button.extraExtraSmall),
                      child: Center(
                        widthFactor: 1,
                        child: Text('Close menu', style: textStyle?.copyWith(fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return Semantics(
        container: true,
        liveRegion: true,
        explicitChildNodes: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: pointsUp ? <Widget>[arrow, body] : <Widget>[body, arrow],
        ),
      );
    },
    child: OutlinedButton(onPressed: () => setState(() => _open = !_open), child: Text(widget.label)),
  );
}

class _FlyoutArrowClipper extends CustomClipper<Path> {
  const _FlyoutArrowClipper({required this.pointsUp});

  final bool pointsUp;

  @override
  Path getClip(Size size) => pointsUp
      ? (Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close())
      : (Path()
          ..lineTo(size.width, 0)
          ..lineTo(size.width / 2, size.height)
          ..close());

  @override
  bool shouldReclip(covariant _FlyoutArrowClipper oldClipper) => pointsUp != oldClipper.pointsUp;
}

class _TourScreen extends StatefulWidget {
  const _TourScreen();

  @override
  State<_TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<_TourScreen> {
  int _run = 0;
  bool _finished = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Onboarding example')),
    body: UIShowcaseSequence(
      key: ValueKey<int>(_run),
      steps: const <Object>['create', 'filter', 'details'],
      startDelay: const Duration(milliseconds: 400),
      onFinish: () => setState(() => _finished = true),
      child: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.all(Theme.of(context).uiTheme.size.offset.regular),
          children: <Widget>[
            Text(_finished ? 'Tour completed.' : 'Follow the three highlighted actions.'),
            for (final (step, label, description) in const <(String, String, String)>[
              ('create', 'Create appointment', 'Start a new appointment here.'),
              ('filter', 'Filter appointments', 'Narrow the list by date or employee.'),
              ('details', 'Open appointment', 'Open the selected appointment to see its details.'),
            ])
              Padding(
                padding: EdgeInsets.symmetric(vertical: Theme.of(context).uiTheme.size.offset.regular),
                child: UIShowcase(
                  step: step,
                  description: '$description Tap the highlighted action to continue.',
                  action: const UIShowcaseAction.dismiss(label: 'Close tour'),
                  child: OutlinedButton(
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label activated'))),
                    child: Text(label),
                  ),
                ),
              ),
            TextButton(
              onPressed: () => setState(() {
                _finished = false;
                _run++;
              }),
              child: const Text('Start again'),
            ),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close tour')),
          ],
        ),
      ),
    ),
  );
}
