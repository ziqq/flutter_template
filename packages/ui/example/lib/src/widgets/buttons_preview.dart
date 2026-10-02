import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_example.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

/// SDK button variants, with stable loading bounds and disabled actions.
class UIButtonsPreview extends StatelessWidget {
  const UIButtonsPreview({super.key});

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'UI Buttons',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = Theme.of(context).uiTheme.size.offset;
          final width = (278 + spacing.regular * 2).clamp(0.0, constraints.maxWidth);
          return Wrap(
            spacing: spacing.regular,
            runSpacing: spacing.regular,
            children: [
              for (final secondary in const [false, true])
                SizedBox(
                  width: width,
                  child: ComponentPreviewGroup(
                    title: secondary ? 'Secondary actions' : 'Primary actions',
                    description: 'Four sizes, disabled, loading, and icon variants.',
                    icon: Icons.smart_button_outlined,
                    child: _ButtonVariants(secondary: secondary),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}

class _ButtonVariants extends StatelessWidget {
  const _ButtonVariants({required this.secondary});

  final bool secondary;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 278,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        for (final (size, label) in const [
          (UIButtonSize.large, 'large'),
          (UIButtonSize.medium, 'medium'),
          (UIButtonSize.small, 'small'),
          (UIButtonSize.extraSmall, 'extra small'),
        ])
          if (secondary)
            UIButton.secondary(
              onPressed: () => showPreviewSnackBar(context, 'Secondary $label activated'),
              size: size,
              child: Text('Secondary $label'),
            )
          else
            UIButton(
              onPressed: () => showPreviewSnackBar(context, 'Primary $label activated'),
              size: size,
              child: Text('Primary $label'),
            ),
        if (secondary) ...[
          UIButton.secondary(onPressed: null, child: const Text('Disabled secondary')),
          UIButton.secondary(onPressed: () {}, loading: true, child: const Text('Loading secondary')),
          UIButton.secondaryIcon(
            onPressed: () => showPreviewSnackBar(context, 'Secondary icon activated'),
            icon: const Icon(Icons.add),
            label: const Text('Add secondary'),
          ),
        ] else ...[
          UIButton(onPressed: null, child: const Text('Disabled primary')),
          UIButton(
            onPressed: null,
            onLongPress: () => showPreviewSnackBar(context, 'Long press activated'),
            child: const Text('Long press only'),
          ),
          UIButton(onPressed: () {}, loading: true, child: const Text('Loading primary')),
          UIButton.icon(
            onPressed: () => showPreviewSnackBar(context, 'Primary icon activated'),
            icon: const Icon(Icons.add),
            label: const Text('Add primary'),
          ),
        ],
      ],
    ),
  );
}
