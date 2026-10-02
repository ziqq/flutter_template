/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 12 September 2025
 */

import 'package:ui/ui.dart';

/// {@template preview_section}
/// A section widget with an optional title and a sliver child.
/// {@endtemplate}
class PreviewSection extends StatelessWidget {
  const PreviewSection({required this.child, this.trailing, this.title, super.key});

  /// Returns the shared content inset for catalog preview surfaces.
  static EdgeInsets contentPaddingOf(BuildContext context) {
    final spacing = Theme.of(context).uiTheme.size.offset;
    return EdgeInsets.fromLTRB(spacing.regular, spacing.extraExtraSmall, spacing.regular, spacing.regular);
  }

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Trailing widget in the header row.
  final Widget? trailing;

  /// The title of this section.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title?.trim();
    final effectiveTrailing = trailing;
    final theme = Theme.of(context);
    final uiTheme = theme.uiTheme;
    final headerHeight = uiTheme.size.button.small + uiTheme.size.offset.small * 2;
    final sectionName = effectiveTitle?.replaceAll(' ', '_').toLowerCase();
    return SliverMainAxisGroup(
      slivers: <Widget>[
        if (effectiveTitle != null && effectiveTitle.isNotEmpty) ...[
          SliverPersistentHeader(
            key: ValueKey<String>('cards_header_$sectionName'),
            floating: true,
            pinned: true,
            delegate: _SliverHeaderDelegate(
              maxHeight: headerHeight,
              minHeight: headerHeight,
              child: DecoratedBox(
                key: ValueKey<String>('cards_header_box_$sectionName'),
                decoration: BoxDecoration(
                  color: uiTheme.color.surface,
                  border: Border(
                    top: BorderSide(color: uiTheme.color.border),
                    left: BorderSide(color: uiTheme.color.border),
                    right: BorderSide(color: uiTheme.color.border),
                  ),
                  borderRadius: .only(
                    topLeft: .circular(uiTheme.size.corner.regular),
                    topRight: .circular(uiTheme.size.corner.regular),
                  ),
                ),
                child: Padding(
                  padding: .symmetric(horizontal: uiTheme.size.offset.regular, vertical: uiTheme.size.offset.small),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Expanded(child: UIText.titleLarge(effectiveTitle, maxLines: 1, overflow: .ellipsis)),
                      ?effectiveTrailing,
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
                key: ValueKey<String>('cards_body_${sectionName ?? 'untitled'}'),
                decoration: BoxDecoration(
                  color: uiTheme.color.surface,
                  border: Border(
                    bottom: BorderSide(color: uiTheme.color.border),
                    left: BorderSide(color: uiTheme.color.border),
                    right: BorderSide(color: uiTheme.color.border),
                  ),
                  borderRadius: .only(
                    bottomLeft: .circular(uiTheme.size.corner.regular),
                    bottomRight: .circular(uiTheme.size.corner.regular),
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
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) =>
      child != oldDelegate.child || minHeight != oldDelegate.minHeight || maxHeight != oldDelegate.maxHeight;
}
