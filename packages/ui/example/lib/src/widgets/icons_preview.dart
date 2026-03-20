import 'package:example/src/common/widgets/preview_section.dart';
import 'package:flutter/cupertino.dart' show CupertinoColors, CupertinoDynamicColor;
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

/// Default size of icon.
const double _kDefaultIconSize = 40;

/// A map of all LeafRenderObjectWidget icons available in the UI package with a specific size.
Map<String, LeafRenderObjectWidget> _renderObjectIcons = <String, LeafRenderObjectWidget>{
  'app_store_logo': const AppStoreLogo(),
  'google_play_logo': const GooglePlayLogo(),
  'avatar': const UIIcon$Avatar(),
  'photo': const UIIcon$Photo$Stub(),
};

/// A preview of all [UIIcons] icons available in the UI package.
class UIIconsPreview extends StatelessWidget {
  UIIconsPreview({required Map<String, Object> icons, required this.title, super.key})
    : _icons = icons,
      assert(
        icons.values.every((icon) => icon is LeafRenderObjectWidget || icon is IconData),
        'Icons must be a Map<String, Object> where Object is either LeafRenderObjectWidget or IconData',
      );

  const UIIconsPreview.font({super.key}) : _icons = UIIcons.values, title = 'UI Icons (Font)';

  /// Icons map to preview.
  final Map<String, Object> _icons;

  /// The title of this section.
  final String title;

  @override
  Widget build(BuildContext context) => PreviewSection(title: title, child: _CustomIconsPreview(_icons));
}

/// A preview of all [LeafRenderObjectWidget] icons available in the UI package.
class UIIconsPreview$LeafRenderObject extends StatelessWidget {
  const UIIconsPreview$LeafRenderObject({super.key});

  @override
  Widget build(BuildContext context) =>
      PreviewSection(title: 'UI Icons', child: _CustomIconsPreview(_renderObjectIcons));
}

/// A preview of custom icons.
class _CustomIconsPreview extends StatelessWidget {
  _CustomIconsPreview(
    Map<String, Object> icons, {
    super.key, // ignore: unused_element_parameter
  }) : _icons = icons,
       assert(
         icons.values.every((icon) => icon is LeafRenderObjectWidget || icon is IconData),
         'Icons must be a Map<String, Object> where Object is either LeafRenderObjectWidget or IconData',
       );

  /// Icons map to preview.
  final Map<String, Object> _icons;

  static bool _usePadding(String iconName) => switch (iconName) {
    'avatar' || 'photo' => false,
    _ => true,
  };

  static bool _useBackgroundColor(String iconName) => switch (iconName) {
    'avatar' || 'photo' => false,
    _ => true,
  };

  static Widget _buildChild(Map<String, Object> children, int index, {bool dimensionless = false}) {
    final icon = children.values.elementAt(index);
    final name = children.keys.elementAt(index);
    final usePadding = _usePadding(name);
    final useBackgroundColor = _useBackgroundColor(name);
    return switch (icon) {
      LeafRenderObjectWidget() => _IconPreview(
        icon: icon,
        name: name,
        usePadding: usePadding,
        useBackgroundColor: useBackgroundColor,
      ),
      IconData() => _IconPreview.icondata(icon: icon, name: name),
      _ => const SizedBox.shrink(),
    };
  }

  /// Build one column layout
  static List<Widget> _buildOneColumn(
    BuildContext context,
    Map<String, Object> children, {
    bool dimensionless = false,
    double iconSize = _kDefaultIconSize,
  }) => List<Widget>.generate(
    children.length,
    (i) => SizedBox(
      height: iconSize + 16,
      child: _buildChild(children, i, dimensionless: dimensionless),
    ),
    growable: false,
  );

  /// Build two column layout
  static List<Widget> _buildTwoColumn(
    BuildContext context,
    Map<String, Object> children, {
    bool dimensionless = false,
    double iconSize = _kDefaultIconSize,
  }) => List<Widget>.generate((children.length / 2).ceil(), (i) {
    final index = i * 2;
    return SizedBox(
      height: iconSize + 16,
      child: Row(
        spacing: 16,
        children: [
          Expanded(child: _buildChild(children, index)),
          Expanded(
            child: index + 1 < children.length
                ? _buildChild(children, index + 1, dimensionless: dimensionless)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }, growable: false);

  /// Build three column layout
  static List<Widget> _buildThreeColumn(
    BuildContext context,
    Map<String, Object> children, {
    bool dimensionless = false,
    double iconSize = _kDefaultIconSize,
  }) => List<Widget>.generate((children.length / 3).ceil(), (i) {
    final index = i * 3;
    return SizedBox(
      height: iconSize + 16,
      child: Row(
        spacing: 16,
        children: [
          Expanded(child: _buildChild(children, index)),
          Expanded(
            child: index + 1 < children.length
                ? _buildChild(children, index + 1, dimensionless: dimensionless)
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: index + 2 < children.length
                ? _buildChild(children, index + 2, dimensionless: dimensionless)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }, growable: false);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        spacing: 10,
        children: switch (constraints.maxWidth ~/ 250) {
          0 || 1 => _buildOneColumn(context, _icons),
          2 => _buildTwoColumn(context, _icons),
          _ => _buildThreeColumn(context, _icons),
        },
      ),
    ),
  );
}

/// {@template icons_preview}
/// _IconPreview widget.
/// {@endtemplate}
class _IconPreview extends StatelessWidget {
  /// {@macro icons_preview}
  const _IconPreview({
    required LeafRenderObjectWidget icon,
    required this.name,
    this.usePadding = true,
    this.useBackgroundColor = true,
    super.key, // ignore: unused_element_parameter
  }) : _icon = icon;

  const _IconPreview.icondata({
    required IconData icon,
    required this.name,
    super.key, // ignore: unused_element_parameter
  }) : _icon = icon,
       usePadding = true,
       useBackgroundColor = true;

  final String name;
  final Object? _icon;
  final bool usePadding;
  final bool useBackgroundColor;

  /// Copy icon code to clipboard
  void _copy(BuildContext context) {
    final text =
        'SizedBox.square(\n'
        ' dimension: 24,\n'
        ' child: const $_icon(),\n'
        ')';
    Clipboard.setData(ClipboardData(text: text)).ignore();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('Copied to clipboard $name icon')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = usePadding ? 0 : 16;
    final child = switch (_icon) {
      LeafRenderObjectWidget() => SizedBox.square(dimension: 24.0 + delta, child: _icon),
      IconData() => Icon(_icon, color: theme.colorScheme.secondary, size: 24.0),
      _ => const SizedBox.shrink(),
    };
    return GestureDetector(
      onTap: () => _copy(context),
      child: Row(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: useBackgroundColor
                    ? CupertinoDynamicColor.resolve(CupertinoColors.quaternarySystemFill, context)
                    : null,
              ),
              child: Padding(padding: usePadding ? const EdgeInsets.all(8) : EdgeInsets.zero, child: child),
            ),
          ),
          Flexible(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
