/*
 * Date: 04 June 2026
 */

import 'package:flutter_template_name/src/common/util/screen_util.dart';
import 'package:meta/meta.dart';
import 'package:ui/ui.dart';

// TODO(ziqq): Maybe should be replace intro the `ui` package
//
/// {@template common_bottom_space}
/// CommonBottomSpacer widget.
///
/// This widget is used to add space at the bottom of the screen.
/// {@endtemplate}
class CommonBottomSpacer extends StatelessWidget {
  /// {@macro common_bottom_space}
  const CommonBottomSpacer({super.key});

  /// Return a sliver widget that adds a bottom spacer.
  /// This is useful for adding space at the bottom of a scrollable area.
  /// {@macro common_bottom_space}
  @literal
  const factory CommonBottomSpacer.sliver() = _CommonBottomSpacer$Sliver;

  /// {@macro common_bottom_space}
  static bool hasBottomNotchOf(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.viewPadding.bottom > 0 || mq.systemGestureInsets.bottom != 0;
  }

  /// {@macro common_bottom_space}
  static double bottomNotchOf(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.viewPadding.bottom > 0 ? mq.viewPadding.bottom : mq.systemGestureInsets.bottom;
  }

  /// This method is used to calculate the height of the bottom space.
  ///
  /// {@macro common_bottom_space}
  static double heightOf(BuildContext context) => CommonBottomSpacer.hasBottomNotchOf(context)
      ? CommonBottomSpacer.bottomNotchOf(context)
      : Theme.of(context).uiTheme.size.offset.regular;

  /// Get the keyboard height.
  /// If [adaptive] is true, the height will be increased by the regular offset when the keyboard is open,
  /// or the regular offset when the keyboard is closed.
  static double keyboardOf(BuildContext context, {bool adaptive = false}) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    if (adaptive) {
      if (keyboardIsOpenOf(context)) {
        return bottom + Theme.of(context).uiTheme.size.offset.regular;
      } else {
        return heightOf(context);
      }
    }
    return bottom;
  }

  /// Check device keyboard is opening.
  static bool keyboardIsOpenOf(BuildContext context) => CommonBottomSpacer.keyboardOf(context) > 0;

  /// Return the [FloatingActionButtonLocation] based on the bottom notch.
  /// If the bottom notch is present, the [FloatingActionButtonLocation.centerDocked] is returned.
  /// Otherwise, the [FloatingActionButtonLocation.centerFloat] is returned.
  /// This is used to ensure that the floating action button is positioned correctly
  /// based on the presence of a bottom notch.
  /// {@macro common_bottom_space}
  static FloatingActionButtonLocation fabLocationOf(BuildContext context) =>
      CommonBottomSpacer.hasBottomNotchOf(context)
      ? FloatingActionButtonLocation.centerDocked
      : FloatingActionButtonLocation.centerFloat;

  /// Return the height of the tab bar based on the orientation.
  /// If the orientation is portrait, the height is equal to the [kTabBarHeight].
  /// If the orientation is landscape, the height is equal to the small button size from the theme.
  /// This is used to ensure that the tab bar is always visible and has enough space for the content.
  /// This method is used to calculate the height of the tab bar.
  /// {@macro common_bottom_space}
  static double tabBarHeightOf(BuildContext context) =>
      context.orientation == Orientation.portrait ? kTabBarHeight : Theme.of(context).uiTheme.size.button.small;

  @override
  Widget build(BuildContext context) => SizedBox(height: CommonBottomSpacer.heightOf(context));
}

/// Sliver version of [CommonBottomSpacer].
/// {@macro common_bottom_spacer}
class _CommonBottomSpacer$Sliver extends CommonBottomSpacer {
  /// {@macro common_bottom_spacer}
  const _CommonBottomSpacer$Sliver({
    super.key, // ignore: unused_element_parameter
  });

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(child: super.build(context));
}
