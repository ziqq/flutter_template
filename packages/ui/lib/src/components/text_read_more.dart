import 'package:ui/ui.dart';

/// How an expandable description is initially shortened.
enum UITextReadMoreTrimMode { length, line }

/// Displays a shortened description with a keyboard-accessible expansion action.
class UITextReadMore extends StatefulWidget {
  const UITextReadMore(
    this.data, {
    this.trimExpandedText,
    this.trimCollapsedText,
    this.colorClickableText,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = UITextReadMoreTrimMode.length,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaler,
    this.semanticsLabel,
    this.moreStyle,
    this.lessStyle,
    this.delimiter = '\u2026',
    this.delimiterStyle,
    this.callback,
    super.key,
  }) : assert(trimLength >= 0, 'trimLength must not be negative.'),
       assert(trimLines > 0, 'trimLines must be positive.');

  final String data;
  final String? trimExpandedText;
  final String? trimCollapsedText;
  final Color? colorClickableText;
  final int trimLength;
  final int trimLines;
  final UITextReadMoreTrimMode trimMode;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final TextStyle? moreStyle;
  final TextStyle? lessStyle;
  final String delimiter;
  final TextStyle? delimiterStyle;

  /// Called with `true` while the description is collapsed.
  final ValueChanged<bool>? callback;

  @override
  State<UITextReadMore> createState() => _UITextReadMoreState();
}

class _UITextReadMoreState extends State<UITextReadMore> {
  bool _collapsed = true;

  @override
  void didUpdateWidget(covariant UITextReadMore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) _collapsed = true;
  }

  void _toggle() {
    setState(() => _collapsed = !_collapsed);
    widget.callback?.call(_collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final direction = widget.textDirection ?? Directionality.of(context);
    final scaler = widget.textScaler ?? MediaQuery.textScalerOf(context);
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);
    final strings = UILocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final characters = widget.data.characters;
        final painter = TextPainter(
          text: TextSpan(text: widget.data, style: style),
          textDirection: direction,
          textScaler: scaler,
          maxLines: widget.trimLines,
          locale: locale,
        );
        final bool canExpand;
        try {
          painter.layout(maxWidth: constraints.maxWidth);
          canExpand = widget.trimMode == UITextReadMoreTrimMode.length
              ? characters.length > widget.trimLength
              : painter.didExceedMaxLines;
        } finally {
          painter.dispose();
        }
        final shortened = _collapsed && canExpand && widget.trimMode == UITextReadMoreTrimMode.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: shortened ? characters.take(widget.trimLength).toString() : widget.data),
                  if (shortened) TextSpan(text: widget.delimiter, style: widget.delimiterStyle),
                ],
              ),
              style: style,
              textAlign: widget.textAlign,
              textDirection: direction,
              textScaler: scaler,
              locale: locale,
              semanticsLabel: widget.semanticsLabel,
              maxLines: _collapsed && canExpand && widget.trimMode == UITextReadMoreTrimMode.line
                  ? widget.trimLines
                  : null,
              overflow: _collapsed && canExpand ? TextOverflow.ellipsis : TextOverflow.clip,
            ),
            if (canExpand)
              TextButton(
                onPressed: _toggle,
                style: TextButton.styleFrom(
                  foregroundColor: widget.colorClickableText ?? Theme.of(context).uiTheme.color.accent,
                ),
                child: Text(
                  _collapsed
                      ? widget.trimCollapsedText ?? strings.moreLabel
                      : widget.trimExpandedText ?? strings.lessLabel,
                  style: _collapsed ? widget.moreStyle : widget.lessStyle,
                ),
              ),
          ],
        );
      },
    );
  }
}
