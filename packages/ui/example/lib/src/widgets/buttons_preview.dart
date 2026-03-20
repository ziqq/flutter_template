import 'package:example/src/common/widgets/preview_section.dart';
import 'package:flutter/cupertino.dart' show CupertinoColors, CupertinoDynamicColor;
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

const double _kColumnWidth = 278;

class UIButtonsPreview extends StatelessWidget {
  const UIButtonsPreview({super.key});

  @override
  Widget build(BuildContext context) => const PreviewSection(
    title: 'UI Buttons',
    child: Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _FilledPrimaryButtons(),
          _FilledSecondaryButtons(),
          // _FilledDestructiveButtons(),
          // _OutlinedButtons(),
          // _TextButtons(),
          // _IconButtons(),
        ],
      ),
    ),
  );
}

class _FilledPrimaryButtons extends StatelessWidget {
  const _FilledPrimaryButtons();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _kColumnWidth,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Primary button',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
            ),
          ),
        ),

        // Regular button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, height: 1.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Primary regular'),
        ),

        // Medium button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Primary medium'),
        ),

        // Small button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(38),
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Primary small'),
        ),
      ],
    ),
  );
}

class _FilledSecondaryButtons extends StatelessWidget {
  const _FilledSecondaryButtons();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _kColumnWidth,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Secondary button',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
            ),
          ),
        ),

        // Regular button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .15),
            textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, height: 1.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Secondary regular'),
        ),

        // Medium button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(44),
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .15),
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, height: 1.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Secondary medium'),
        ),

        // Small button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(38),
            foregroundColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .15),
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Secondary small'),
        ),
      ],
    ),
  );
}
