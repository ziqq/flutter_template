/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 */

import 'package:ui/ui.dart';

/// {@template chip_filter}
/// UIChipFilter widget.
/// {@endtemplate}
class UIChipFilter extends StatelessWidget {
  /// {@macro chip_filter}
  const UIChipFilter({required this.text, this.onDeleted, this.avatar, super.key});

  /// Text of chip
  final String text;

  /// Avatar of chip
  final UIImageSource? avatar;

  /// Deleted callback
  final void Function()? onDeleted;

  @override
  Widget build(BuildContext context) {
    return UIChip(
      textColor: Colors.white,
      onClear: onDeleted,
      label: text,
      leading: avatar == null ? null : UIAvatar(size: Theme.of(context).iconTheme.size, source: avatar, rounded: true),
      backgroundColor: Theme.of(context).uiTheme.color.accent,
      closeBtnBackgroundColor: Colors.white.withValues(alpha: 0.25),
      closeBtnColor: Colors.white,
    );
  }
}
