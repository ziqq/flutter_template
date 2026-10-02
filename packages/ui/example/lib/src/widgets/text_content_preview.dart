import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

class TextContentPreview extends StatefulWidget {
  const TextContentPreview({super.key});
  @override
  State<TextContentPreview> createState() => _TextContentPreviewState();
}

class _TextContentPreviewState extends State<TextContentPreview> {
  int _linkTaps = 0;
  static const _text =
      'Long text should remain readable in narrow layouts and with large text. '
      'The expanded state exposes the complete content, while the collapsed state keeps a predictable number of lines. '
      'Use the More and Less buttons with a mouse, touch, or keyboard. Emoji such as 👨‍👩‍👧‍👦 count as one grapheme rather than being cut into fragments.';

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Text content',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          const ComponentPreviewGroup(
            title: 'Read more by lines',
            child: UITextReadMore(_text, trimMode: UITextReadMoreTrimMode.line, trimLines: 2),
          ),
          const ComponentPreviewGroup(
            title: 'Read more by graphemes',
            child: UITextReadMore(_text, trimMode: UITextReadMoreTrimMode.length, trimLength: 100),
          ),
          ComponentPreviewGroup(
            title: 'Styled tags and inline action',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                RichTextBuilder(
                  text: 'A <b>strong label</b> and an <action>inline action</action>.',
                  tags: {
                    'b': const RichTextTag(style: TextStyle(fontWeight: FontWeight.bold)),
                    'action': RichTextTag(
                      style: TextStyle(
                        color: Theme.of(context).uiTheme.color.accent,
                        decoration: TextDecoration.underline,
                      ),
                      onTap: () => setState(() => _linkTaps++),
                    ),
                  },
                ),
                Text('Inline action invoked $_linkTaps times'),
              ],
            ),
          ),
          const ComponentPreviewGroup(
            title: 'Wrapping, ellipsis, and selection',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Text(_text, maxLines: 2, overflow: TextOverflow.ellipsis),
                SelectableText('Select and copy this text. Shared styles still follow the current theme.'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
