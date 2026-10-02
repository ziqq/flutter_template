/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 13 August 2026
 */

import 'package:example/src/catalog/catalog_category.dart';
import 'package:ui/ui.dart';

/// Displays all previews belonging to one catalog category.
class CatalogCategoryScreen extends StatelessWidget {
  /// Creates a scrollable preview screen for [category].
  const CatalogCategoryScreen({required this.category, this.showBackButton = true, super.key});

  /// Category whose preview slivers are displayed.
  final CatalogCategory category;

  /// Whether the app bar reserves the route back action.
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previews = category.buildPreviews(context);
    final sectionSpacing = theme.uiTheme.size.offset.large;
    return Scaffold(
      key: ValueKey<String>('catalog_category_screen_${category.id}'),
      backgroundColor: theme.uiTheme.color.secondaryBackground,
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: showBackButton,
        backgroundColor: theme.uiTheme.color.secondaryBackground,
        foregroundColor: theme.uiTheme.color.text,
        surfaceTintColor: theme.uiTheme.color.secondaryBackground,
        title: Text(category.title, style: theme.textTheme.titleLarge),
      ),
      body: CustomScrollView(
        key: ValueKey<String>('catalog_category_scroll_${category.id}'),
        slivers: <Widget>[
          SliverPadding(
            padding: .only(
              left: theme.uiTheme.size.offset.regular,
              right: theme.uiTheme.size.offset.regular,
              top: theme.uiTheme.size.offset.regular,
            ),
            sliver: SliverMainAxisGroup(
              slivers: <Widget>[
                for (var index = 0; index < previews.length; index++) ...<Widget>[
                  if (index > 0) SliverToBoxAdapter(child: SizedBox(height: sectionSpacing)),
                  previews[index],
                ],
                SliverToBoxAdapter(child: SizedBox(height: theme.uiTheme.size.offset.large)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
