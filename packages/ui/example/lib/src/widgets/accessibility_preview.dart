import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:example/src/widgets/sheets_preview.dart';
import 'package:ui/ui.dart';

class AccessibilityPreview extends StatefulWidget {
  const AccessibilityPreview({super.key});
  @override
  State<AccessibilityPreview> createState() => _AccessibilityPreviewState();
}

class _AccessibilityPreviewState extends State<AccessibilityPreview> {
  double _scale = 1;
  bool _rtl = false;
  bool _long = false;
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_scale));
    final direction = _rtl ? TextDirection.rtl : TextDirection.ltr;
    return PreviewSection(
      title: 'Accessibility',
      child: Padding(
        padding: PreviewSection.contentPaddingOf(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text('Text scale: ${_scale.toStringAsFixed(1)}×'),
            Slider(
              label: '${_scale.toStringAsFixed(1)}×',
              value: _scale,
              min: 1,
              max: 2,
              divisions: 4,
              onChanged: (scale) => setState(() => _scale = scale),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Right-to-left layout'),
              value: _rtl,
              onChanged: (value) => setState(() => _rtl = value),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Long labels'),
              value: _long,
              onChanged: (value) => setState(() => _long = value),
            ),
            MediaQuery(
              data: media,
              child: Directionality(
                textDirection: direction,
                child: ComponentPreviewGroup(
                  title: 'Focusable controls',
                  description: 'Use Tab, Shift+Tab, Enter, and Space. The sandbox also applies to its form route.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      UIListTile(
                        title: Text(
                          _long
                              ? 'A longer label that must remain readable when the text scale changes'
                              : 'Notifications',
                        ),
                        subtitle: const Text('Direction-aware leading and trailing content'),
                        leading: const Icon(Icons.notifications_outlined),
                        trailing: Switch.adaptive(
                          value: _enabled,
                          onChanged: (value) => setState(() => _enabled = value),
                        ),
                      ),
                      const UITextInput(labelText: 'Keyboard focus', helperText: 'Tab moves focus to the next action'),
                      Builder(
                        builder: (context) => UIButton(
                          onPressed: () => Navigator.of(context).push<String>(
                            UISheetRoute<String>(
                              barrierLabel: 'Dismiss accessible form',
                              child: MediaQuery(
                                data: media,
                                child: Directionality(
                                  textDirection: direction,
                                  child: const SheetBackground.withTopMargin(child: CatalogFormSheet()),
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            _long ? 'Open a form with a deliberately longer button label' : 'Open accessible form',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
