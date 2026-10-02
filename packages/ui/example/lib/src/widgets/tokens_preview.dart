import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

/// Renders the named sizing tokens from the active UI theme.
class UITokensPreview extends StatelessWidget {
  const UITokensPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final sizes = Theme.of(context).uiTheme.size;
    return PreviewSection(
      title: 'Sizing tokens',
      child: Padding(
        padding: PreviewSection.contentPaddingOf(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: sizes.offset.regular,
          children: <Widget>[
            for (final (name, scheme) in <(String, SizeScheme)>[
              ('offset', sizes.offset),
              ('corner', sizes.corner),
              ('button', sizes.button),
              ('icon', sizes.icon),
              ('avatar', sizes.avatar),
            ])
              _TokenScale(name: name, scheme: scheme),
          ],
        ),
      ),
    );
  }
}

class _TokenScale extends StatelessWidget {
  const _TokenScale({required this.name, required this.scheme});

  final String name;
  final SizeScheme scheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <String, double>{
      'regular': scheme.regular,
      'extraExtraSmall': scheme.extraExtraSmall,
      'extraSmall': scheme.extraSmall,
      'small': scheme.small,
      'medium': scheme.medium,
      'large': scheme.large,
      'secondary': ?scheme.secondary,
      'xl': ?scheme.xl,
      'xxl': ?scheme.xxl,
    };
    return ComponentPreviewGroup(
      title: name,
      description: 'Theme.of(context).uiTheme.size.$name',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: theme.uiTheme.size.offset.regular,
        children: <Widget>[
          for (final entry in entries.entries)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: theme.uiTheme.size.offset.extraSmall,
              children: <Widget>[
                SelectableText('${entry.key}: ${entry.value.toStringAsFixed(0)}'),
                ExcludeSemantics(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.uiTheme.color.selected,
                      border: Border.all(color: theme.uiTheme.color.accent),
                      borderRadius: BorderRadius.circular(name == 'corner' ? entry.value : 0),
                    ),
                    child: SizedBox(
                      width: name == 'corner' ? 100 : entry.value,
                      height: name == 'offset'
                          ? 12
                          : name == 'corner'
                          ? 56
                          : entry.value,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
