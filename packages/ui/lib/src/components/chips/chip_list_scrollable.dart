import 'package:flutter/services.dart' show HapticFeedback;
import 'package:ui/ui.dart';

/// A horizontal collection whose selection remains owned by the caller.
class UIChipListScrollable extends StatelessWidget {
  const UIChipListScrollable({
    this.items = const [],
    this.currentIndex,
    this.height,
    this.textColor,
    this.padding,
    this.activeTextColor,
    this.backgroundColor,
    this.activeBackgroundColor,
    this.onTap,
    this.useHapticFeedback = true,
    super.key,
  });
  final List<ScrollableChip$Item> items;
  final int? currentIndex;
  final double? height;
  final Color? textColor;
  final Color? activeTextColor;
  final Color? backgroundColor;
  final Color? activeBackgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool useHapticFeedback;
  final void Function(int? index, ScrollableChip$Item? item)? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height ?? Theme.of(context).uiTheme.size.button.small + Theme.of(context).uiTheme.size.offset.small,
    child: ListView.separated(
      padding: padding,
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(width: Theme.of(context).uiTheme.size.offset.small),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = currentIndex == index;
        return ChoiceChip(
          avatar: item.icon,
          label: Text(item.counter == null ? item.title : '${item.title} (${item.counter})'),
          selected: selected,
          backgroundColor: backgroundColor,
          selectedColor: activeBackgroundColor,
          labelStyle: TextStyle(color: selected ? activeTextColor : textColor),
          onSelected: onTap == null
              ? null
              : (_) {
                  if (useHapticFeedback) HapticFeedback.selectionClick().ignore();
                  onTap!(selected ? null : index, selected ? null : item);
                },
        );
      },
    ),
  );
}

/// Immutable data for a scrollable choice chip.
@immutable
class ScrollableChip$Item {
  const ScrollableChip$Item({required this.title, this.alias, this.counter, this.icon});
  final String title;
  final String? alias;
  final int? counter;
  final Widget? icon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScrollableChip$Item &&
          other.title == title &&
          other.alias == alias &&
          other.counter == counter &&
          other.icon == icon;
  @override
  int get hashCode => Object.hash(title, alias, counter, icon);
}
