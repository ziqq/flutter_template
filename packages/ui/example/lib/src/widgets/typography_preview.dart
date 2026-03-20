import 'package:example/src/common/widgets/preview_section.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

/// A preview of the typography styles defined in the app's theme.
class TypographyPreview extends StatelessWidget {
  const TypographyPreview({super.key});

  Widget _buildRow(BuildContext context, TextStyle? style, String title) => Row(
    children: [
      Flexible(
        child: Text(title, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      Text(' (${style?.fontSize?.toStringAsFixed(0)})', style: style),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    const spcerSmall = SizedBox(height: 10);
    const spacerLarge = SizedBox(height: 24);
    return PreviewSection(
      title: 'UI Typography',
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(context, textTheme.displayLarge, 'Display large'),
            spcerSmall,
            _buildRow(context, textTheme.displayMedium, 'Display medium'),
            spcerSmall,
            _buildRow(context, textTheme.displaySmall, 'Display small'),
            spacerLarge,
            _buildRow(context, textTheme.headlineLarge, 'Headline large'),
            spcerSmall,
            _buildRow(context, textTheme.headlineMedium, 'Headline medium'),
            spcerSmall,
            _buildRow(context, textTheme.headlineSmall, 'Headline small'),
            spacerLarge,
            _buildRow(context, textTheme.titleLarge, 'Title large'),
            spcerSmall,
            _buildRow(context, textTheme.titleMedium, 'Title medium'),
            spcerSmall,
            _buildRow(context, textTheme.titleSmall, 'Title small'),
            spacerLarge,
            _buildRow(context, textTheme.bodyLarge, 'Body large'),
            spcerSmall,
            _buildRow(context, textTheme.bodyMedium, 'Body medium'),
            spcerSmall,
            _buildRow(context, textTheme.bodySmall, 'Body small'),
            spacerLarge,
            _buildRow(context, textTheme.labelLarge, 'Label large'),
            spcerSmall,
            _buildRow(context, textTheme.labelMedium, 'Label medium'),
            spcerSmall,
            _buildRow(context, textTheme.labelSmall, 'Label small'),
          ],
        ),
      ),
    );
  }
}
