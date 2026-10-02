import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

class PricePreview extends StatefulWidget {
  const PricePreview({super.key});

  @override
  State<PricePreview> createState() => _PricePreviewState();
}

class _PricePreviewState extends State<PricePreview> {
  final _price = TextEditingController();
  final _text = TextEditingController();

  @override
  void dispose() {
    _price.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uiTheme = Theme.of(context).uiTheme;
    return PreviewSection(
      title: 'Price and grapheme counter',
      child: Padding(
        padding: PreviewSection.contentPaddingOf(context),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final groups = <Widget>[
              ComponentPreviewGroup(
                title: 'Price input',
                description: 'Grouping, decimal digits, and selection-aware formatting.',
                icon: Icons.payments_outlined,
                child: UITextInput(
                  controller: _price,
                  labelText: 'Price',
                  backgroundColor: uiTheme.color.tertiaryBackground,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: const [TextInputFormatter$Price()],
                  helperText: 'Spaces group thousands; comma separates two decimal digits',
                ),
              ),
              ComponentPreviewGroup(
                title: 'Text counter',
                description: 'Remaining characters counted as Unicode graphemes.',
                icon: Icons.short_text_rounded,
                child: UITextFieldCounterWrapper(
                  controller: _text,
                  maxLength: 60,
                  child: UITextInput(
                    controller: _text,
                    labelText: 'Count emoji as graphemes',
                    backgroundColor: uiTheme.color.tertiaryBackground,
                    maxLines: 3,
                  ),
                ),
              ),
            ];
            if (constraints.maxWidth < 680) {
              return Column(spacing: uiTheme.size.offset.regular, children: groups);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: uiTheme.size.offset.regular,
              children: groups.map((group) => Expanded(child: group)).toList(growable: false),
            );
          },
        ),
      ),
    );
  }
}
