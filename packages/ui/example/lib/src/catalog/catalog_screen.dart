/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 13 August 2026
 */

import 'package:example/src/catalog/catalog_category.dart';
import 'package:example/src/catalog/catalog_navigation.dart';
import 'package:example/src/catalog/catalog_theme_button.dart';
import 'package:example/src/catalog/categories_screen.dart';
import 'package:example/src/catalog/category_screen.dart';
import 'package:ui/ui.dart';

/// Selects a phone navigation flow or a persistent wide category layout.
class CatalogScreen extends StatefulWidget {
  /// Creates the responsive catalog shell.
  const CatalogScreen({required this.onToggleTheme, super.key});

  /// Called when the theme action is activated in either layout.
  final VoidCallback onToggleTheme;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  CatalogCategory _selected = CatalogCategory.media;

  void _selectWide(CatalogCategory category) => setState(() => _selected = category);

  void _openPhone(CatalogCategory category) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/catalog/${category.id}'),
        builder: (_) => CatalogCategoryScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth <= 600) {
        return CatalogCategoriesScreen(onSelected: _openPhone, onToggleTheme: widget.onToggleTheme);
      }
      final theme = Theme.of(context);
      return Scaffold(
        key: const ValueKey<String>('catalog_split_view'),
        backgroundColor: theme.uiTheme.color.secondaryBackground,
        body: SafeArea(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: constraints.maxWidth >= 1024 ? 320 : 260,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 56,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: theme.uiTheme.size.offset.regular),
                        child: Row(
                          children: <Widget>[
                            Expanded(child: Text('UI KIT', style: theme.textTheme.titleLarge)),
                            CatalogThemeButton(onPressed: widget.onToggleTheme),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: CatalogNavigation(selected: _selected, onSelected: _selectWide),
                    ),
                  ],
                ),
              ),
              VerticalDivider(width: 1, color: theme.dividerColor),
              Expanded(child: CatalogCategoryScreen(category: _selected, showBackButton: false)),
            ],
          ),
        ),
      );
    },
  );
}
