/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 13 August 2026
 */

import 'package:example/src/catalog/catalog_category.dart';
import 'package:example/src/catalog/catalog_navigation.dart';
import 'package:example/src/catalog/catalog_theme_button.dart';
import 'package:ui/ui.dart';

/// Displays the full category list as the phone catalog home screen.
class CatalogCategoriesScreen extends StatelessWidget {
  /// Creates the phone catalog home screen.
  const CatalogCategoriesScreen({required this.onSelected, required this.onToggleTheme, super.key});

  /// Opens the selected category as a separate phone route.
  final ValueChanged<CatalogCategory> onSelected;

  /// Toggles the example theme.
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey<String>('catalog_categories_screen'),
    backgroundColor: Theme.of(context).uiTheme.color.secondaryBackground,
    appBar: AppBar(
      title: Text('UI KIT', style: Theme.of(context).textTheme.titleLarge),
      actions: <Widget>[CatalogThemeButton(onPressed: onToggleTheme)],
      backgroundColor: Theme.of(context).uiTheme.color.secondaryBackground,
      foregroundColor: Theme.of(context).uiTheme.color.text,
    ),
    body: SafeArea(top: false, child: CatalogNavigation(onSelected: onSelected)),
  );
}
