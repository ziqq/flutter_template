/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 09 July 2026
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// {@template rich_text_tag}
/// Describes how a single inline tag is rendered by [RichTextBuilder].
///
/// A tag is any `<name>...</name>` pair inside the source text, where `name`
/// is the key this configuration is registered under. The inner content is
/// passed to the resolvers below.
///
/// Resolution order:
/// 1. If [builder] is provided, it fully owns the span for this tag and
///    [style]/[onTap]/[mouseCursor] are ignored. Use it for custom spans such
///    as [WidgetSpan] or nested styling. When [builder] wires its own gesture
///    recognizer, the caller is responsible for its lifecycle.
/// 2. Otherwise a [TextSpan] is produced with [style]. When [onTap] is not
///    null, [RichTextBuilder] creates and disposes a [TapGestureRecognizer]
///    for it automatically, so no leaks occur.
/// {@endtemplate}
class RichTextTag {
  /// {@macro rich_text_tag}
  const RichTextTag({this.style, this.onTap, this.builder, this.mouseCursor});

  /// Fully custom span builder for the tag content.
  ///
  /// When provided, it takes precedence over [style], [onTap] and
  /// [mouseCursor]. The [String] argument is the text between the tags.
  final InlineSpan Function(String content)? builder;

  /// The style applied to the tag content when [builder] is not provided.
  ///
  /// Falls back to the widget's base text style when null.
  final TextStyle? style;

  /// Tap callback for the tag content.
  ///
  /// When not null, [RichTextBuilder] owns and disposes the underlying
  /// [TapGestureRecognizer].
  final VoidCallback? onTap;

  /// The mouse cursor used when [onTap] is provided.
  ///
  /// Defaults to [SystemMouseCursors.click] for tappable tags.
  final MouseCursor? mouseCursor;
}

/// {@template rich_text_builder}
/// A [Text.rich] widget that renders an arbitrary string containing inline
/// `<tag>...</tag>` markup into styled and/or tappable spans.
///
/// Unlike a fixed-purpose consent widget, [RichTextBuilder] accepts any set of
/// tags via [tags]. Each key is a tag name and each value describes how the
/// matching content is rendered (style, tap handler, or a custom span builder).
///
/// Tags may be nested-free, self-contained pairs and may repeat any number of
/// times. Unknown tags (present in the text but absent from [tags]) are kept as
/// plain text, including their tag markers.
///
/// Gesture recognizers created for tags with [RichTextTag.onTap] are owned by
/// this widget and disposed automatically.
///
/// Example:
/// ```dart
/// RichTextBuilder(
///   text: 'Соглашаюсь с <t>офертой</t> и <p>политикой</p>. <b>Джеки Чан</b>',
///   tags: <String, RichTextTag>{
///     't': RichTextTag(style: linkStyle, onTap: _openTerms),
///     'p': RichTextTag(style: linkStyle, onTap: _openPrivacy),
///     'b': RichTextTag(style: const TextStyle(fontWeight: FontWeight.bold)),
///     'i': RichTextTag(builder: (text) => TextSpan(text: text, style: italic)),
///   },
/// );
/// ```
/// {@endtemplate}
class RichTextBuilder extends StatefulWidget {
  /// {@macro rich_text_builder}
  const RichTextBuilder({
    required this.text,
    required this.tags,
    this.textStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    super.key,
  });

  /// The raw text containing `<tag>...</tag>` markup to render.
  final String text;

  /// The set of supported tags keyed by tag name.
  ///
  /// {@macro rich_text_tag}
  final Map<String, RichTextTag> tags;

  /// The base style applied to plain text and to tags without an explicit
  /// [RichTextTag.style].
  ///
  /// Falls back to [DefaultTextStyle] when null.
  final TextStyle? textStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The maximum number of lines the text may span before wrapping/clipping.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// Whether the text should break at soft line breaks.
  final bool softWrap;

  @override
  State<RichTextBuilder> createState() => _RichTextBuilderState();
}

/// State for widget [RichTextBuilder].
class _RichTextBuilderState extends State<RichTextBuilder> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];
  List<InlineSpan> _spans = const <InlineSpan>[];
  TextStyle _textStyle = const TextStyle();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textStyle = widget.textStyle ?? DefaultTextStyle.of(context).style;
    _rebuildSpans();
  }

  @override
  void didUpdateWidget(covariant RichTextBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textStyle != widget.textStyle) {
      _textStyle = widget.textStyle ?? DefaultTextStyle.of(context).style;
    }
    _rebuildSpans();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  /// Disposes and clears all owned gesture recognizers.
  void _disposeRecognizers() {
    for (final recognizer in _recognizers) recognizer.dispose();
    _recognizers.clear();
  }

  /// Builds a regular expression matching any of the registered [tags].
  ///
  /// Returns null when there are no tags to match. Tag names are escaped so
  /// arbitrary characters are supported safely.
  RegExp? _buildTagRegExp() {
    if (widget.tags.isEmpty) return null;
    final alternation = widget.tags.keys.map(RegExp.escape).join('|');
    return RegExp('<($alternation)>(.*?)</\\1>', dotAll: true);
  }

  /// Parses [widget.text] into styled/tappable spans, recreating recognizers.
  void _rebuildSpans() {
    _disposeRecognizers();

    final text = widget.text;
    final tagRegExp = _buildTagRegExp();

    if (tagRegExp == null) {
      _spans = <InlineSpan>[TextSpan(text: text, style: _textStyle)];
      return;
    }

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in tagRegExp.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start), style: _textStyle));
      }

      final name = match.group(1);
      final content = match.group(2) ?? '';
      final tag = name == null ? null : widget.tags[name];
      final tagBuilder = tag?.builder;

      if (tag == null) {
        // Unknown tag: render content as plain text.
        spans.add(TextSpan(text: content, style: _textStyle));
      } else if (tagBuilder != null) {
        spans.add(tagBuilder(content));
      } else if (tag.onTap != null) {
        final recognizer = TapGestureRecognizer()..onTap = tag.onTap;
        _recognizers.add(recognizer);
        spans.add(
          TextSpan(
            text: content,
            style: tag.style ?? _textStyle,
            recognizer: recognizer,
            mouseCursor: tag.mouseCursor ?? SystemMouseCursors.click,
            semanticsLabel: content,
          ),
        );
      } else {
        spans.add(TextSpan(text: content, style: tag.style ?? _textStyle));
      }

      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: _textStyle));
    }

    _spans = spans;
  }

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(children: _spans, style: _textStyle),
    overflow: widget.overflow ?? TextOverflow.clip,
    textAlign: widget.textAlign,
    maxLines: widget.maxLines,
    textWidthBasis: TextWidthBasis.parent,
    softWrap: widget.softWrap,
  );
}
