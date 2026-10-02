import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

class ChipsPreview extends StatefulWidget {
  const ChipsPreview({super.key});

  @override
  State<ChipsPreview> createState() => _ChipsPreviewState();
}

class _ChipsPreviewState extends State<ChipsPreview> {
  bool _selected = false;
  bool _filter = true;
  int? _index;

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Chips',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          ComponentPreviewGroup(
            title: 'Choice, status, and removal',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const UIChip(label: 'Tag', useBoxShadow: false),
                const UIChip.small(label: 'Small tag', useBoxShadow: false),
                UIChipChoice(
                  label: 'Selectable',
                  selected: _selected,
                  onSelected: (selected) => setState(() => _selected = selected),
                ),
                const UIChipChoice(label: 'Unavailable', isAvailable: false),
                const UIChipOnline(),
                const UIChipBlocked(),
                if (_filter) UIChipFilter(text: 'Removable filter', onDeleted: () => setState(() => _filter = false)),
                if (!_filter)
                  TextButton(onPressed: () => setState(() => _filter = true), child: const Text('Restore filter')),
              ],
            ),
          ),
          ComponentPreviewGroup(
            title: 'Scrollable selection',
            description: 'One current collection API; no duplicate legacy scrolled list.',
            child: UIChipListScrollable(
              currentIndex: _index,
              onTap: (index, _) => setState(() => _index = index),
              items: const [
                ScrollableChip$Item(title: 'All', counter: 24),
                ScrollableChip$Item(title: 'Active', counter: 8),
                ScrollableChip$Item(title: 'Archived', counter: 16),
                ScrollableChip$Item(title: 'Long category label'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
