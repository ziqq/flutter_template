import 'package:ui/ui.dart';

/// {@template list_loader_indicator}
/// UIListLoaderIndicator widget.
/// {@endtemplate}
class UIListLoaderIndicator extends StatelessWidget {
  /// {@macro list_loader_indicator}
  const UIListLoaderIndicator({this.visible = true, this.padding, super.key});

  /// Is visible?
  /// Default is `true`.
  final bool visible;

  /// The padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Visibility(
    visible: visible,
    child: SizedBox(
      height: 40,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: const Center(child: UILoaderIndicator()),
      ),
    ),
  );
}
