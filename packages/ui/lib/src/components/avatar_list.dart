import 'package:ui/ui.dart';

/// Overlapping typed image sources, with an optional hidden-count badge.
class UIAvatarList extends StatelessWidget {
  const UIAvatarList({
    required this.avatars,
    this.display = 3,
    this.avatarSize = 32,
    this.withCounter = true,
    this.semanticLabel,
    super.key,
  }) : assert(display > 0, 'display must be positive.'),
       assert(avatarSize > 0, 'avatarSize must be positive.');

  final List<UIImageSource?> avatars;
  final int display;
  final double avatarSize;
  final bool withCounter;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final count = avatars.length.clamp(0, display);
    final step = avatarSize * .75;
    if (count == 0) return const SizedBox.shrink();
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: avatarSize + (count - 1) * step,
        height: avatarSize,
        child: Stack(
          children: [
            for (var index = 0; index < count; index++)
              PositionedDirectional(
                start: index * step,
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).uiTheme.color.surface, width: 2),
                  ),
                  child: SizedBox.square(
                    dimension: avatarSize,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        UIAvatar.circle(source: avatars[index], size: avatarSize),
                        if (withCounter && index == count - 1 && avatars.length > count)
                          DecoratedBox(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x99000000)),
                            child: Center(
                              child: Text(
                                '+${avatars.length - count}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
