import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/src/components/border_radius.dart';
import 'package:ui/src/theme/theme.dart';

/// Selects hexadecimal colors in a bounded-width grid or horizontal list.
/// Accepts RGB, RRGGBB and AARRGGBB notation, optionally prefixed with #.
/// [selectedColor] is an index, so duplicate values remain distinct swatches.
class UIColorPicker extends StatelessWidget {
  const UIColorPicker({
    required this.colors,
    this.onChanged,
    this.padding,
    this.bulletSize,
    this.backgroundColor,
    this.selectedColor = 0,
    this.useHorizontal = false,
    this.useHapticFeedback = true,
    this.rows = 2,
    super.key,
  }) : assert(rows > 0, 'Row count must be positive.'),
       assert(
         bulletSize == null || bulletSize > 0 && bulletSize < double.infinity,
         'Size must be positive and finite.',
       ),
       assert(selectedColor == null || selectedColor >= 0, 'Selected index must be nonnegative.');

  const UIColorPicker.horizontal({
    required this.colors,
    this.onChanged,
    this.padding,
    this.bulletSize,
    this.backgroundColor,
    this.selectedColor = 0,
    this.useHapticFeedback = true,
    super.key,
  }) : useHorizontal = true,
       rows = 1,
       assert(
         bulletSize == null || bulletSize > 0 && bulletSize < double.infinity,
         'Size must be positive and finite.',
       ),
       assert(selectedColor == null || selectedColor >= 0, 'Selected index must be nonnegative.');

  final List<String> colors;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry? padding;
  final double? bulletSize;
  final Color? backgroundColor;
  final int? selectedColor;
  final bool useHorizontal;
  final bool useHapticFeedback;
  final int rows;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context).uiTheme;
    final spacing = theme.size.offset.extraExtraSmall;
    final diameter = bulletSize ?? theme.size.button.small;

    Widget swatch(int index, double size) => _ColorSwatch(
      label: colors[index],
      color: _parseColor(colors[index]),
      selected: selectedColor == index,
      diameter: math.max(0, size - 4),
      onTap: onChanged == null
          ? null
          : () {
              if (useHapticFeedback) HapticFeedback.mediumImpact().ignore();
              onChanged!(colors[index]);
            },
    );

    return Material(
      color: backgroundColor ?? theme.color.surface,
      borderRadius: UIBorderRadius.regular(context),
      clipBehavior: Clip.antiAlias,
      child: useHorizontal
          ? SizedBox(
              height: math.max(kMinInteractiveDimension, diameter + theme.size.offset.small * 2),
              child: ListView.separated(
                primary: false,
                scrollDirection: Axis.horizontal,
                padding: padding ?? EdgeInsets.symmetric(horizontal: theme.size.offset.regular),
                itemCount: colors.length,
                itemBuilder: (_, index) => swatch(index, diameter),
                separatorBuilder: (_, _) => SizedBox(width: theme.size.offset.small),
              ),
            )
          : Padding(
              padding: padding ?? EdgeInsets.all(theme.size.offset.regular / 1.3),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  assert(constraints.hasBoundedWidth, 'A color grid requires bounded width.');
                  final columns = bulletSize == null
                      ? (colors.length / rows).ceil().clamp(1, colors.length)
                      : ((constraints.maxWidth + spacing) / (bulletSize! + spacing)).floor().clamp(1, colors.length);
                  final cellSize = (constraints.maxWidth - (columns - 1) * spacing) / columns;
                  final size = math.min(bulletSize ?? cellSize, cellSize);
                  return GridView.builder(
                    primary: false,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: colors.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                    ),
                    itemBuilder: (_, index) => Center(child: swatch(index, size)),
                  );
                },
              ),
            ),
    );
  }
}

Color _parseColor(String value) {
  final hex = value.startsWith('#') ? value.substring(1) : value;
  if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) throw FormatException('Invalid hexadecimal color.', value);
  return switch (hex.length) {
    3 => Color(int.parse('ff${hex.split('').map((digit) => '$digit$digit').join()}', radix: 16)),
    6 => Color(int.parse('ff$hex', radix: 16)),
    8 => Color(int.parse(hex, radix: 16)),
    _ => throw FormatException('Expected RGB, RRGGBB or AARRGGBB color.', value),
  };
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.diameter,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final double diameter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    selected: selected,
    enabled: onTap != null,
    child: SizedBox.square(
      dimension: math.max(kMinInteractiveDimension, diameter),
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        customBorder: const CircleBorder(),
        child: Center(
          child: SizedBox.square(
            dimension: diameter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: AnimatedPadding(
                  duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(selected ? 2 : 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
