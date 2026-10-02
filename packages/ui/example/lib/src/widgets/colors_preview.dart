import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

class UIColorsPreview extends StatelessWidget {
  const UIColorsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PreviewSection(
      title: 'UI Colors',
      child: Padding(
        padding: PreviewSection.contentPaddingOf(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: theme.uiTheme.size.offset.regular,
          children: [
            ComponentPreviewGroup(
              title: 'Light palette',
              description: 'Semantic colors resolved for light surfaces.',
              icon: Icons.light_mode_outlined,
              child: _ColorsPreview($generateUIColorsForBrightness(Brightness.light)),
            ),
            ComponentPreviewGroup(
              title: 'Dark palette',
              description: 'The matching semantic roles for dark surfaces.',
              icon: Icons.dark_mode_outlined,
              child: _ColorsPreview($generateUIColorsForBrightness(Brightness.dark)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorsPreview extends StatelessWidget {
  const _ColorsPreview(this.colors);

  final UIColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: theme.uiTheme.size.offset.regular,
      runSpacing: theme.uiTheme.size.offset.regular,
      children: colors
          .toMap()
          .entries
          .map((entry) {
            final name = entry.key;
            final color = entry.value;
            return SizedBox(
              width: 120,
              height: 100,
              child: Column(
                key: ValueKey(name),
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: theme.uiTheme.size.icon.large,
                    child: Material(
                      color: color,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(theme.uiTheme.size.corner.small),
                    ),
                  ),
                  SizedBox(height: theme.uiTheme.size.offset.extraSmall),
                  UIText.labelMedium(name, textAlign: TextAlign.center),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
