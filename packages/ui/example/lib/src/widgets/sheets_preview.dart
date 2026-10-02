import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

class SheetsPreview extends StatefulWidget {
  const SheetsPreview({super.key});

  @override
  State<SheetsPreview> createState() => _SheetsPreviewState();
}

class _SheetsPreviewState extends State<SheetsPreview> {
  bool _dismissible = true;
  SheetDismissalMode _mode = SheetDismissalMode.slide;
  String _result = 'No sheet result yet';

  Future<void> _open(Widget child, {bool snapping = false}) async {
    final result = await Navigator.of(context).push<String>(
      UISheetRoute<String>(
        barrierLabel: 'Dismiss example sheet',
        barrierDismissible: _dismissible,
        draggable: _dismissible,
        dismissalMode: _mode,
        snappingConfig: snapping ? const SheetSnappingConfig([1 / 3, 2 / 3, 1]) : SheetSnappingConfig.full,
        child: SheetBackground.withTopMargin(child: child),
      ),
    );
    if (!mounted) return;
    setState(() => _result = result == null ? 'Sheet cancelled' : 'Sheet returned: $result');
  }

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Sheets',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: ComponentPreviewGroup(
        title: 'Snap points, keyboard, and typed result',
        description: 'Pinned actions remain outside the scrollable. Barrier and drag dismissal are configurable; Cancel and Back remain available.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Allow barrier and drag dismissal'),
              value: _dismissible,
              onChanged: (value) => setState(() => _dismissible = value),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final mode in SheetDismissalMode.values)
                  ChoiceChip(
                    label: Text(mode.name),
                    selected: mode == _mode,
                    onSelected: (_) => setState(() => _mode = mode),
                  ),
              ],
            ),
            UIButton(onPressed: () => _open(const CatalogFormSheet()), child: const Text('Open keyboard form')),
            UIButton(
              onPressed: () => _open(const _SelectionSheet(), snapping: true),
              child: const Text('Open snapping selection'),
            ),
            Semantics(liveRegion: true, child: Text(_result)),
          ],
        ),
      ),
    ),
  );
}

/// Shared form for sheet and accessibility demonstrations.
class CatalogFormSheet extends StatefulWidget {
  const CatalogFormSheet({super.key});

  @override
  State<CatalogFormSheet> createState() => _CatalogFormSheetState();
}

class _CatalogFormSheetState extends State<CatalogFormSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Keyboard form'),
      leading: IconButton(
        tooltip: 'Cancel form',
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Form(
        key: _form,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  UITextInput(
                    controller: _name,
                    labelText: 'Name',
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: 16),
                  const UITextInput(
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  const UITextInput(
                    labelText: 'Notes',
                    minLines: 3,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Use Tab to move between fields. The form scrolls and the action remains above the keyboard.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: UIButton(
                  onPressed: () {
                    if (_form.currentState!.validate()) Navigator.of(context).pop(_name.text.trim());
                  },
                  child: const Text('Save form'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SelectionSheet extends StatefulWidget {
  const _SelectionSheet();
  @override
  State<_SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends State<_SelectionSheet> {
  int? _selection;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Snapping selection')),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 40,
              itemBuilder: (context, index) => UIListTile(
                title: Text('Option ${index + 1}'),
                trailing: index == _selection ? const Icon(Icons.check) : null,
                onTap: () => setState(() => _selection = index),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UIButton(
                  onPressed: _selection == null ? null : () => Navigator.of(context).pop('Option ${_selection! + 1}'),
                  child: const Text('Confirm selection'),
                ),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel selection')),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
