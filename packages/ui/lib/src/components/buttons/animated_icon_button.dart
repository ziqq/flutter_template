import 'package:ui/ui.dart';

/// An icon action whose unread count can replay notification feedback.
class UIAnimatedIconButton extends StatefulWidget {
  const UIAnimatedIconButton({
    required this.icon,
    this.counter,
    this.textColor,
    this.badgeColor,
    this.onPressed,
    this.tooltip,
    this.hasAnimation = false,
    super.key,
  }) : assert(counter == null || counter >= 0, 'counter must not be negative.');

  final Widget icon;
  final int? counter;
  final Color? textColor;
  final Color? badgeColor;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool hasAnimation;

  @override
  State<UIAnimatedIconButton> createState() => _UIAnimatedIconButtonState();
}

class _UIAnimatedIconButtonState extends State<UIAnimatedIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  bool _reducedMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion) _controller.stop();
  }

  @override
  void didUpdateWidget(covariant UIAnimatedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.hasAnimation || _reducedMotion) {
      _controller.stop();
    } else if (oldWidget.counter != widget.counter || !oldWidget.hasAnimation) {
      _controller.forward(from: 0).ignore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = IconButton(onPressed: widget.onPressed, tooltip: widget.tooltip, icon: widget.icon);
    return AnimatedBuilder(
      animation: _controller,
      child: button,
      builder: (context, child) {
        final progress = _controller.value;
        final turns = widget.hasAnimation && !_reducedMotion
            ? (progress < .5
                      ? Curves.elasticOut.transform(progress * 2)
                      : Curves.easeOut.transform((1 - progress) * 2)) *
                  .05
            : 0.0;
        return Badge.count(
          count: widget.counter ?? 0,
          isLabelVisible: (widget.counter ?? 0) > 0,
          backgroundColor: widget.badgeColor,
          textColor: widget.textColor,
          child: Transform.rotate(angle: turns * 6.283185307179586, child: child),
        );
      },
    );
  }
}
