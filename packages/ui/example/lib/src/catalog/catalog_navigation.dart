/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 14 August 2026
 */

import 'package:example/src/catalog/catalog_category.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

/// Displays searchable category navigation for phone and persistent layouts.
class CatalogNavigation extends StatefulWidget {
  /// Creates category navigation with an optional persistent selection.
  const CatalogNavigation({required this.onSelected, this.selected, super.key});

  /// Category highlighted in the persistent wide pane.
  final CatalogCategory? selected;

  /// Called with the activated category.
  final ValueChanged<CatalogCategory> onSelected;

  @override
  State<CatalogNavigation> createState() => _CatalogNavigationState();
}

class _CatalogNavigationState extends State<CatalogNavigation> {
  late final Map<CatalogCategory, FocusNode> _categoryFocusNodes;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  String _query = '';

  List<CatalogCategory> get _visibleCategories {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return CatalogCategory.values;
    return CatalogCategory.values
        .where((category) => '${category.title} ${category.description}'.toLowerCase().contains(query))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode(debugLabel: 'Catalog search');
    _categoryFocusNodes = <CatalogCategory, FocusNode>{
      for (final c in CatalogCategory.values) c: FocusNode(debugLabel: 'Catalog category ${c.id}'),
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    for (final focusNode in _categoryFocusNodes.values) focusNode.dispose();
    super.dispose();
  }

  void _search(String query) => setState(() => _query = query);

  void _moveCategoryFocus(int delta) {
    final categories = _visibleCategories;
    if (categories.isEmpty) return;
    final focusedIndex = categories.indexWhere((category) => _categoryFocusNodes[category]?.hasFocus ?? false);
    final selectedIndex = widget.selected == null ? -1 : categories.indexOf(widget.selected!);
    final origin = focusedIndex >= 0 ? focusedIndex : selectedIndex;
    final nextIndex = (origin + delta).clamp(0, categories.length - 1);
    final nextCategory = categories[nextIndex];
    _categoryFocusNodes[nextCategory]?.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _categoryFocusNodes[nextCategory]?.context;
      if (context != null) Scrollable.ensureVisible(context, alignment: .5, duration: const .new(milliseconds: 120));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = _visibleCategories;
    final spacing = theme.uiTheme.size.offset;
    return UIDismissKeyboard(
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowDown): _MoveCatalogFocusIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowUp): _MoveCatalogFocusIntent(-1),
          SingleActivator(LogicalKeyboardKey.keyF, meta: true): _FocusCatalogSearchIntent(),
          SingleActivator(LogicalKeyboardKey.keyF, control: true): _FocusCatalogSearchIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            _MoveCatalogFocusIntent: CallbackAction<_MoveCatalogFocusIntent>(
              onInvoke: (intent) {
                _moveCategoryFocus(intent.delta);
                return null;
              },
            ),
            _FocusCatalogSearchIntent: CallbackAction<_FocusCatalogSearchIntent>(
              onInvoke: (_) {
                _searchFocusNode.requestFocus();
                return null;
              },
            ),
          },
          child: FocusTraversalGroup(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(spacing.regular, 0, spacing.regular, spacing.extraSmall),
                  child: UISearchInput(
                    key: const ValueKey<String>('catalog_search'),
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _search,
                    onSuffixTap: _searchFocusNode.requestFocus,
                  ),
                ),
                Expanded(
                  child: categories.isEmpty
                      ? _CatalogEmptySearch(query: _query)
                      : ListView.separated(
                          key: const ValueKey<String>('catalog_category_list'),
                          padding: EdgeInsets.fromLTRB(spacing.regular, 0, spacing.regular, spacing.small),
                          itemCount: categories.length,
                          separatorBuilder: (_, _) => SizedBox(height: spacing.extraExtraSmall),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _CatalogCategoryTile(
                              category: category,
                              selected: widget.selected == category,
                              compact: widget.selected != null,
                              focusNode: _categoryFocusNodes[category],
                              onPressed: () => widget.onSelected(category),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveCatalogFocusIntent extends Intent {
  const _MoveCatalogFocusIntent(this.delta);

  final int delta;
}

class _FocusCatalogSearchIntent extends Intent {
  const _FocusCatalogSearchIntent();
}

class _CatalogEmptySearch extends StatelessWidget {
  const _CatalogEmptySearch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.uiTheme.size.offset.regular),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.uiTheme.size.offset.extraSmall,
          children: <Widget>[
            Icon(CupertinoIcons.search, size: theme.uiTheme.size.icon.large, color: theme.uiTheme.color.textSecondary),
            Text('No components found', style: theme.textTheme.titleSmall, textAlign: TextAlign.center),
            Text(
              'Try another name instead of “${query.trim()}”.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.uiTheme.color.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogCategoryTile extends StatelessWidget {
  const _CatalogCategoryTile({
    required this.category,
    required this.selected,
    required this.compact,
    required this.focusNode,
    required this.onPressed,
  });

  final CatalogCategory category;
  final bool selected;
  final bool compact;
  final FocusNode? focusNode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.uiTheme.size.offset;
    final borderRadius = UIBorderRadius.regular(context);
    final actionColor = selected ? theme.uiTheme.color.accent : theme.uiTheme.color.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        key: ValueKey<String>('catalog_category_surface_${category.id}'),
        color: selected ? theme.uiTheme.color.selected : theme.uiTheme.color.secondaryBackground,
        borderRadius: borderRadius,
        child: InkWell(
          key: ValueKey<String>('catalog_category_${category.id}'),
          borderRadius: borderRadius,
          focusNode: focusNode,
          focusColor: theme.uiTheme.color.ring.withValues(alpha: .14),
          hoverColor: theme.uiTheme.color.selected.withValues(alpha: .72),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: theme.uiTheme.size.button.large),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.small, vertical: spacing.extraSmall),
              child: Row(
                children: <Widget>[
                  Icon(category.icon, size: theme.uiTheme.size.icon.regular, color: actionColor),
                  SizedBox(width: spacing.small),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: spacing.extraExtraSmall,
                      children: <Widget>[
                        Text(
                          category.title,
                          key: ValueKey<String>('catalog_category_title_${category.id}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          category.description,
                          key: ValueKey<String>('catalog_category_description_${category.id}'),
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.uiTheme.color.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.extraSmall),
                  Icon(Icons.chevron_right_rounded, size: theme.uiTheme.size.icon.small, color: actionColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
