import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

/// Exercises caller-owned selection, option replacement, validation, and reset.
class SelectionPreview extends StatefulWidget {
  const SelectionPreview({super.key});

  @override
  State<SelectionPreview> createState() => _SelectionPreviewState();
}

class _SelectionPreviewState extends State<SelectionPreview> {
  final _form = GlobalKey<FormState>();
  final _selection = ValueNotifier<String?>('Design');
  List<String> _options = const ['Design', 'Development', 'Research'];
  String _result = 'Choose an option, validate, or reset to Design.';

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Generic selection',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: ComponentPreviewGroup(
        title: 'Form and controller',
        description:
            'SDK dropdown on desktop/web; confirmed wheel picker on mobile. Removed options cannot remain selected.',
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              UISelect<String>(
                items: _options,
                controller: _selection,
                labelText: 'Work area',
                displayStringForOption: (option) => option,
                validator: (option) => option == null ? 'Select a work area' : null,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => setState(
                      () => _result = _form.currentState!.validate()
                          ? 'Selected: ${_selection.value}'
                          : 'Selection required',
                    ),
                    child: const Text('Validate selection'),
                  ),
                  TextButton(
                    onPressed: () {
                      _selection.value = null;
                    },
                    child: const Text('Clear selection'),
                  ),
                  TextButton(
                    onPressed: () {
                      _form.currentState!.reset();
                      setState(() => _result = 'Reset to ${_selection.value ?? "none"}');
                    },
                    child: const Text('Reset form'),
                  ),
                  TextButton(
                    onPressed: () => setState(
                      () => _options = _options.length == 3
                          ? const ['Development', 'Research']
                          : const ['Design', 'Development', 'Research'],
                    ),
                    child: const Text('Replace options'),
                  ),
                ],
              ),
              Semantics(liveRegion: true, child: Text(_result)),
            ],
          ),
        ),
      ),
    ),
  );
}
