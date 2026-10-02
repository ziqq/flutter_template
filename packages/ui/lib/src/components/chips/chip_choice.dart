import 'package:ui/ui.dart';

/// A caller-controlled SDK choice chip styled with UI tokens.
class UIChipChoice extends StatelessWidget {
  const UIChipChoice({
    required this.label,
    this.selected = false,
    this.onTap,
    this.onSelected,
    this.isAvailable = true,
    this.hasError = false,
    this.minWidth = 0,
    this.labelPadding,
    this.borderRadius,
    super.key,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSelected;
  final bool isAvailable;
  final bool hasError;
  final double minWidth;
  final EdgeInsetsGeometry? labelPadding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minWidth: minWidth),
    child: ChoiceChip(
      label: Text(label),
      labelPadding: labelPadding,
      selected: selected,
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? UIBorderRadius.small(context)),
      labelStyle: hasError ? TextStyle(color: Theme.of(context).colorScheme.error) : null,
      onSelected: isAvailable && (onTap != null || onSelected != null)
          ? (value) {
              onSelected?.call(value);
              onTap?.call();
            }
          : null,
    ),
  );
}
