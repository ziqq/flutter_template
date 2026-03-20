import 'package:flutter/cupertino.dart' show CupertinoColors, CupertinoDynamicColor;
import 'package:ui/ui.dart';

/// {@template preview_section}
/// A section widget with an optional title and a child.
/// {@endtemplate}
class PreviewSection extends StatelessWidget {
  const PreviewSection({required this.child, this.traling, this.title, super.key});

  /// The title of this section.
  final String? title;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Traling widget in the header row.
  final Widget? traling;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? CupertinoColors.secondarySystemBackground
        : CupertinoColors.systemBackground;
    return SliverMainAxisGroup(
      slivers: <Widget>[
        if (title != null && title!.isNotEmpty) ...[
          SliverPersistentHeader(
            key: ValueKey<String>('preview_section_header_${title?.replaceAll(' ', '_').toLowerCase()}'),
            floating: true,
            // pinned: true,
            delegate: _SliverHeaderDelegate(
              maxHeight: 24 * 2,
              minHeight: 24 * 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  color: CupertinoDynamicColor.resolve(backgroundColor, context),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (traling != null) traling!,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              width: constraints.maxWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: CupertinoDynamicColor.resolve(backgroundColor, context),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({required this.child, required this.minHeight, required this.maxHeight});

  final Widget child;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(child: child);

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
