import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:ui/ui.dart';

/// Demonstrates press, notification, error, disclosure, and manually controlled curve motion.
class AnimationsPreview extends StatefulWidget {
  const AnimationsPreview({super.key});

  @override
  State<AnimationsPreview> createState() => _AnimationsPreviewState();
}

class _AnimationsPreviewState extends State<AnimationsPreview> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
  final _shake = UIShakeController();

  bool _systemReduced = false;
  bool _reduced = false;
  bool _expanded = true;
  int _presses = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final systemReduced = MediaQuery.disableAnimationsOf(context);
    if (systemReduced && !_systemReduced) _controller.value = 1;
    _systemReduced = systemReduced;
  }

  @override
  void dispose() {
    _controller.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final spacing = theme.uiTheme.size.offset;
    final reduced = _reduced || mediaQuery.disableAnimations;
    final duration = reduced ? Duration.zero : const Duration(milliseconds: 300);
    return PreviewSection(
      title: 'Motion',
      child: Padding(
        padding: PreviewSection.contentPaddingOf(context),
        child: MediaQuery(
          data: mediaQuery.copyWith(disableAnimations: reduced),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing.regular,
            children: <Widget>[
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile.adaptive(
                  key: const ValueKey<String>('motion_reduce'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reduce motion'),
                  subtitle: Text(
                    mediaQuery.disableAnimations
                        ? 'Enabled by the system. Actions and feedback stay available.'
                        : 'Apply to every example below. Actions and feedback stay available.',
                  ),
                  value: reduced,
                  onChanged: mediaQuery.disableAnimations
                      ? null
                      : (value) => setState(() {
                          _reduced = value;
                          if (value) _controller.value = 1;
                        }),
                ),
              ),
              ComponentPreviewGroup(
                title: 'Press feedback',
                description: 'Press and hold to compare scale down and scale up. The surrounding layout stays still.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: spacing.regular,
                  children: <Widget>[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final minimumWidth = mediaQuery.textScaler.scale(240);
                        final width = constraints.maxWidth >= minimumWidth * 2 + spacing.large
                            ? (constraints.maxWidth - spacing.large) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: spacing.large,
                          runSpacing: spacing.regular,
                          children: <Widget>[
                            for (final direction in PressTransitionType.values)
                              SizedBox(
                                width: width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: spacing.small,
                                  children: <Widget>[
                                    Text(
                                      direction == PressTransitionType.down ? 'Row · 0.97×' : 'Icon · 1.07×',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.uiTheme.color.textSecondary,
                                      ),
                                    ),
                                    _PressTarget(direction: direction, onPressed: () => setState(() => _presses++)),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    Semantics(
                      liveRegion: true,
                      child: Text('Actions triggered: $_presses', style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
              const _NotificationPreview(),
              ComponentPreviewGroup(
                title: 'Validation feedback',
                description: 'Trigger the same error again to replay the shake. The message never depends on motion.',
                child: ListenableBuilder(
                  listenable: _shake,
                  builder: (context, _) {
                    final color = _shake.hasError ? theme.colorScheme.error : theme.uiTheme.color.textSecondary;
                    final message = Semantics(
                      liveRegion: true,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.uiTheme.color.surface,
                          borderRadius: UIBorderRadius.regular(context),
                          border: Border.all(color: _shake.hasError ? color : theme.uiTheme.color.border),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(spacing.regular),
                          child: Row(
                            children: <Widget>[
                              Icon(_shake.hasError ? Icons.error_outline : Icons.check_circle_outline, color: color),
                              SizedBox(width: spacing.small),
                              Expanded(
                                child: Text(
                                  _shake.error ?? 'Ready to validate.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _shake.hasError ? color : theme.uiTheme.color.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: spacing.regular,
                      children: <Widget>[
                        if (reduced) message else UIShakeTransition(controller: _shake, child: message),
                        Wrap(
                          spacing: spacing.small,
                          runSpacing: spacing.small,
                          children: <Widget>[
                            _MotionAction(
                              label: 'Show error',
                              icon: Icons.replay,
                              primary: true,
                              onPressed: () => _shake.addError('Choose a time to continue.'),
                            ),
                            _MotionAction(
                              label: 'Clear error',
                              icon: Icons.close,
                              onPressed: _shake.hasError ? _shake.clearError : null,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              ComponentPreviewGroup(
                title: 'Expand and collapse',
                description:
                    'Reveal content at its natural height. Collapsed details stay out of view and screen readers.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Semantics(
                      expanded: _expanded,
                      child: ListTile(
                        key: const ValueKey<String>('motion_details_toggle'),
                        shape: RoundedRectangleBorder(borderRadius: UIBorderRadius.regular(context)),
                        contentPadding: EdgeInsets.symmetric(horizontal: spacing.regular),
                        title: const Text('Appointment details'),
                        tileColor: theme.uiTheme.color.surface,
                        subtitle: Text(_expanded ? 'Tap to collapse' : 'Tap to expand'),
                        trailing: AnimatedRotation(
                          turns: _expanded ? .5 : 0,
                          duration: duration,
                          child: const Icon(Icons.expand_more),
                        ),
                        onTap: () => setState(() => _expanded = !_expanded),
                      ),
                    ),
                    ClipRect(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 1, end: _expanded ? 1 : 0),
                        duration: duration,
                        curve: Curves.easeInOutCubic,
                        builder: (_, value, child) => ExcludeSemantics(
                          excluding: !_expanded,
                          child: ShrinkTransition(sizeFactor: value, child: child),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(spacing.regular),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: spacing.small,
                            children: <Widget>[
                              Text('Consultation with Alex Morgan', style: theme.textTheme.bodyLarge),
                              Text(
                                'Tomorrow at 10:30 · 45 minutes',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.uiTheme.color.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ComponentPreviewGroup(
                title: 'Curve comparison',
                description: 'Compare how an element starts and stops. Play once: all markers travel the same distance in 1.2 seconds.',
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: spacing.regular,
                    children: <Widget>[
                      for (final (name, description, curve) in const <(String, String, Curve)>[
                        ('Linear', 'Constant speed', Curves.linear),
                        ('Ease in out', 'Smooth start and stop', Curves.easeInOutCubic),
                        ('Decelerate', 'Fast start, soft stop', Curves.decelerate),
                        ('Bounce out', 'A bouncing finish', Curves.bounceOut),
                      ])
                        _CurveTrack(name: name, description: description, progress: curve.transform(_controller.value)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Timeline · ${(_controller.value * 100).round()}%',
                            key: const ValueKey<String>('motion_timeline_label'),
                            style: theme.textTheme.bodySmall,
                          ),
                          Slider(
                            key: const ValueKey<String>('motion_timeline'),
                            value: _controller.value,
                            semanticFormatterCallback: (value) => '${(value * 100).round()} percent',
                            onChanged: (value) => _controller.value = value,
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: spacing.small,
                        runSpacing: spacing.small,
                        children: <Widget>[
                          _MotionAction(
                            label: _controller.isAnimating
                                ? 'Pause'
                                : _controller.isCompleted
                                ? 'Replay'
                                : _controller.value > 0
                                ? 'Continue'
                                : 'Play',
                            icon: _controller.isAnimating ? Icons.pause : Icons.play_arrow,
                            primary: true,
                            onPressed: () => setState(() {
                              if (reduced) {
                                _controller.value = 1;
                              } else if (_controller.isAnimating) {
                                _controller.stop();
                              } else {
                                _controller.forward(from: _controller.isCompleted ? 0 : _controller.value);
                              }
                            }),
                          ),
                          _MotionAction(
                            label: 'Reset',
                            icon: Icons.restart_alt,
                            onPressed: _controller.value > 0 ? () => _controller.value = 0 : null,
                          ),
                        ],
                      ),
                      if (reduced)
                        Text(
                          'Reduced motion: playback jumps to the end. You can still scrub manually.',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationPreview extends StatefulWidget {
  const _NotificationPreview();

  @override
  State<_NotificationPreview> createState() => _NotificationPreviewState();
}

class _NotificationPreviewState extends State<_NotificationPreview> {
  int _unread = 0;

  void _markAllAsRead() => setState(() => _unread = 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.uiTheme.size.offset;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return ComponentPreviewGroup(
      title: 'Notification badge',
      description: 'Add a notification to replay the bell and badge animation. Tap the bell to mark all as read.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing.regular,
        children: <Widget>[
          Row(
            spacing: spacing.small,
            children: <Widget>[
              UIAnimatedIconButton(
                tooltip: 'Mark all notifications as read',
                icon: const Icon(Icons.notifications_none_rounded),
                counter: _unread > 0 ? _unread : null,
                hasAnimation: _unread > 0 && !reduced,
                badgeColor: theme.colorScheme.error,
                textColor: theme.colorScheme.onError,
                onPressed: _unread > 0 ? _markAllAsRead : null,
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(switch (_unread) {
                    0 => 'No unread notifications',
                    1 => '1 unread notification',
                    _ => '$_unread unread notifications',
                  }, style: theme.textTheme.bodyMedium),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: spacing.small,
            runSpacing: spacing.small,
            children: <Widget>[
              _MotionAction(
                label: 'Add notification',
                icon: Icons.add,
                primary: true,
                onPressed: () => setState(() => _unread++),
              ),
              _MotionAction(
                label: 'Mark all as read',
                icon: Icons.done_all,
                onPressed: _unread > 0 ? _markAllAsRead : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PressTarget extends StatefulWidget {
  const _PressTarget({required this.direction, required this.onPressed});
  final PressTransitionType direction;
  final VoidCallback onPressed;

  @override
  State<_PressTarget> createState() => _PressTargetState();
}

class _PressTargetState extends State<_PressTarget> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiTheme = theme.uiTheme;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final circular = widget.direction == PressTransitionType.up;
    return Semantics(
      label: circular ? 'Press icon' : null,
      child: FocusableActionDetector(
        onShowFocusHighlight: (focused) => setState(() => _focused = focused),
        mouseCursor: SystemMouseCursors.click,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        child: PressTransition(
          enabled: !reduced,
          onTap: widget.onPressed,
          builder: (_, progress, child) =>
              Transform.scale(scale: 1 + (widget.direction.scale - 1) * (reduced ? 0 : progress), child: child),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: uiTheme.size.button.regular),
            child: SizedBox(
              width: circular ? uiTheme.size.button.regular : null,
              height: circular ? uiTheme.size.button.regular : null,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: circular ? uiTheme.color.accent : uiTheme.color.surface,
                  shape: circular ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: circular ? null : UIBorderRadius.regular(context),
                  border: Border.all(color: _focused ? uiTheme.color.text : uiTheme.color.border, width: 2),
                ),
                child: Padding(
                  padding: EdgeInsets.all(circular ? uiTheme.size.offset.small : uiTheme.size.offset.regular),
                  child: circular
                      ? Icon(Icons.add, size: uiTheme.size.icon.regular, color: uiTheme.color.onAccent)
                      : Row(
                          children: <Widget>[
                            Expanded(child: Text('Press row', style: theme.textTheme.bodyLarge)),
                            Icon(
                              Icons.chevron_right,
                              size: uiTheme.size.icon.regular,
                              color: uiTheme.color.textSecondary,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurveTrack extends StatelessWidget {
  const _CurveTrack({required this.name, required this.description, required this.progress});
  final String name;
  final String description;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiTheme = theme.uiTheme;
    return Semantics(
      label: '$name: $description',
      value: '${(progress * 100).round()} percent',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: uiTheme.size.offset.extraSmall,
          children: <Widget>[
            Text('$name · $description', style: theme.textTheme.bodyMedium),
            SizedBox(
              height: uiTheme.size.icon.regular,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox(
                    height: uiTheme.size.offset.extraExtraSmall,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: uiTheme.color.surface,
                        borderRadius: UIBorderRadius.regular(context),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(progress * 2 - 1, 0),
                    child: SizedBox.square(
                      key: ValueKey<String>('motion_marker_$name'),
                      dimension: uiTheme.size.icon.small,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: uiTheme.color.accent, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotionAction extends StatelessWidget {
  const _MotionAction({required this.label, required this.icon, required this.onPressed, this.primary = false});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final uiTheme = Theme.of(context).uiTheme;
    final shape = RoundedRectangleBorder(borderRadius: UIBorderRadius.regular(context));
    final minimumSize = Size(0, uiTheme.size.button.medium);
    final padding = EdgeInsets.symmetric(horizontal: uiTheme.size.offset.regular, vertical: uiTheme.size.offset.small);
    return primary
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: uiTheme.size.icon.small),
            label: Text(label),
            style: FilledButton.styleFrom(
              shape: shape,
              minimumSize: minimumSize,
              padding: padding,
              backgroundColor: uiTheme.color.accent,
              foregroundColor: uiTheme.color.onAccent,
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: uiTheme.size.icon.small),
            label: Text(label),
            style: OutlinedButton.styleFrom(shape: shape, minimumSize: minimumSize, padding: padding),
          );
  }
}
