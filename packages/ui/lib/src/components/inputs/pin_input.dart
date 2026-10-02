/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 28 September 2026
 */

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoColors, CupertinoDynamicColor;
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/src/theme/theme.dart';

/// Displays a numeric code as separate cells while editing it through one text field.
///
/// Adapts PlugFox's [PinCode](https://gist.github.com/PlugFox/305cb44f75e8fa5e5f06424288d373e4)
/// painting approach to the UI theme and a configurable code length.
///
/// The caller owns [controller] and [focusNode] and must dispose them. Set [length]
/// to the number of digits expected by the code provider. [separatorIndex] adds a
/// visual divider before that digit without changing the entered value. Use
/// [textStyle] to adjust the digit typography.
/// The focused cell uses the theme accent; other cells keep a neutral outline.
/// Changed digits scale into place; clearing the code rolls its digits out in order.
/// Set [failed] after a verification attempt fails to shake the red-outlined cells.
/// Set [verified] after the server accepts the code to pulse the green-outlined cells.
/// [onVerified] runs after that transition, so the caller can close the screen.
/// With [MediaQueryData.disableAnimations], digits and result outlines appear
/// immediately and the cursor stays visible without blinking.
/// Long press or secondary click to open the platform's text editing menu.
/// Pasted text uses the same input formatters and [onChanged] callback as typing.
class UIPinInput extends StatefulWidget {
  /// Creates a PIN input with [length] digit cells.
  ///
  /// [label] describes the input for accessibility. [length] must be positive;
  /// user edits accept at most that many ASCII digits and preserve leading zeros.
  /// [separatorIndex], when provided, must be greater than zero and less than
  /// [length]. It groups the cells without adding a character to the code.
  ///
  /// [controller] supplies the text and selection, and [focusNode] manages focus.
  /// Both remain owned by the caller. Programmatically supplied text must contain
  /// at most [length] ASCII digits; input formatters apply to user edits.
  /// [autofocus] defaults to false, and [enabled] defaults to true. Disable the
  /// input while submitting or displaying an accepted code.
  ///
  /// [textStyle] is merged with the theme's display style. Digit colors come from
  /// the theme, and large glyphs are scaled down to fit their cells.
  /// [onChanged] receives user edits, including paste and autofill.
  /// [onSubmitted] handles the keyboard submit action; read the code from
  /// [controller]. The caller decides when to submit a complete code.
  ///
  /// [verified] is an optional caller-owned listenable that defaults to false.
  /// Set it to true after the provider accepts the code. [onVerified] runs after
  /// that transition's final frame, including when reduced motion skips the
  /// transition. An initially true value does not trigger the callback.
  /// [failed] is an optional caller-owned listenable, defaulting to false. Set it
  /// to true after a failed attempt, and reset it to false when the code changes
  /// or another attempt begins. The cells shake while their outlines turn red.
  /// Clearing [controller] rolls digits down and out, with a brief stagger.
  /// Reduced motion skips shaking, pulsing, and digit transitions.
  /// An initially true value displays red immediately. Verified styling takes
  /// precedence when both result values are true.
  /// [key] controls this widget's identity in the tree.
  const UIPinInput({
    required this.label,
    required this.length,
    required this.controller,
    required this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.separatorIndex,
    this.textStyle,
    this.onChanged,
    this.onSubmitted,
    this.verified,
    this.onVerified,
    this.failed,
    super.key,
  }) : assert(length > 0, 'PIN length must be positive.'),
       assert(
         separatorIndex == null || separatorIndex > 0 && separatorIndex < length,
         'Separator index must be within the PIN.',
       );

  /// Whether to focus the text field when it first appears.
  final bool autofocus;

  /// Whether the code can be edited. Defaults to true.
  ///
  /// When false, keyboard and pointer editing are disabled and the cursor is
  /// hidden. Existing digits and cell dimensions are preserved.
  final bool enabled;

  /// Number of digits accepted and displayed. Must be greater than zero.
  final int length;

  /// Index before which to draw a divider, if the code is visually grouped.
  ///
  /// Defaults to no divider. A provided index must be greater than zero and less
  /// than [length], and does not change the value stored in [controller].
  final int? separatorIndex;

  /// Accessible label for the underlying text field.
  final String label;

  /// The code and selection being edited. Owned and disposed by the caller.
  ///
  /// Programmatic changes repaint the input without invoking [onChanged].
  final TextEditingController controller;

  /// Focus for the underlying text field. Owned by the caller.
  final FocusNode focusNode;

  /// Digit style merged with the theme's display style.
  ///
  /// Defaults to the theme's display style. The input applies its theme colors
  /// to distinguish the active digit and scales large glyphs to fit the cells.
  final TextStyle? textStyle;

  /// Called when typing, pasting, or autofill changes the code.
  ///
  /// Receives the filtered digits, including leading zeros. Selection changes
  /// and programmatic changes to [controller] do not invoke this callback.
  final ValueChanged<String>? onChanged;

  /// Called when the keyboard submit action is used.
  ///
  /// Read the submitted value from [controller]. Filling the last cell alone
  /// does not invoke this callback; use [onChanged] for automatic submission.
  final VoidCallback? onSubmitted;

  /// Whether the code has been accepted by its provider. Owned by the caller.
  ///
  /// Defaults to false. A transition to true animates every outline to green,
  /// briefly enlarges the cells, then settles before [onVerified] runs.
  /// It does not infer success from the number of entered digits.
  /// The caller must set [enabled] to false while showing success.
  final ValueListenable<bool>? verified;

  /// Whether the latest verification attempt failed. Owned by the caller.
  ///
  /// Defaults to false. A transition to true shakes the cells and turns their
  /// outlines red. Reset this to false on edits or before retrying, clearing
  /// the red styling.
  /// An initially true value is shown red without an entrance animation.
  /// [verified] styling takes precedence; failure never invokes [onVerified].
  final ValueListenable<bool>? failed;

  /// Called after the success animation finishes and its final frame is painted.
  ///
  /// Only transitions to verified trigger this callback. An initially verified
  /// input is displayed green without reporting another completion.
  /// With reduced motion, the callback follows the immediate green frame.
  final VoidCallback? onVerified;

  @override
  State<UIPinInput> createState() => _UIPinInputState();
}

/// State for [UIPinInput] that manages the theme and builds the input UI.
class _UIPinInputState extends State<UIPinInput> with TickerProviderStateMixin {
  /// Owned by this state so the painter can repaint when an inherited theme changes.
  final ValueNotifier<ThemeData> _theme = ValueNotifier<ThemeData>(ThemeData());

  /// Previous characters identify the cells affected by the current input animation.
  final ValueNotifier<String> _previousText = ValueNotifier<String>('');

  /// Drives paint-only digit transitions through the painter's repaint listenable.
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: kThemeChangeDuration,
    value: 1,
  );

  /// Pulses accepted cells, then holds their settled green frame before completion.
  late final AnimationController _verificationAnimation = AnimationController(
    vsync: this,
    duration: kThemeChangeDuration * 3,
    value: widget.verified?.value == true ? 1 : 0,
  )..addStatusListener(_onVerificationStatusChanged);

  /// Shakes failed attempts without changing code, focus, or success callbacks.
  late final AnimationController _failureAnimation = AnimationController(
    vsync: this,
    duration: kThemeChangeDuration * 2,
    value: widget.failed?.value == true ? 1 : 0,
  );

  /// Keeps each cell's paragraph layout cached while its digit and style are unchanged.
  final List<TextPainter> _textPainters = <TextPainter>[];

  /// Last observed text; selection-only notifications do not restart the animation.
  String _text = '';

  @override
  void initState() {
    super.initState();
    _text = _previousText.value = widget.controller.text;
    widget.verified?.addListener(_onVerifiedChanged);
    widget.failed?.addListener(_onFailedChanged);
    widget.controller.addListener(_onTextChanged);
    _updateTextPainters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    if (_theme.value != theme) _theme.value = theme;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    _verificationAnimation.duration = disableAnimations ? .zero : kThemeChangeDuration * 3;
    _failureAnimation.duration = disableAnimations ? .zero : kThemeChangeDuration * 2;
    if (disableAnimations) {
      _animation.value = 1;
      if (widget.verified?.value == true) _verificationAnimation.value = 1;
      if (widget.failed?.value == true) _failureAnimation.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant UIPinInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_onTextChanged);
      _text = _previousText.value = widget.controller.text;
      widget.controller.addListener(_onTextChanged);
      _animation.value = 1;
    }
    if (oldWidget.length != widget.length) _updateTextPainters();
    if (!identical(oldWidget.verified, widget.verified)) {
      oldWidget.verified?.removeListener(_onVerifiedChanged);
      widget.verified?.addListener(_onVerifiedChanged);
      if (oldWidget.verified?.value != widget.verified?.value) _onVerifiedChanged();
    }
    if (!identical(oldWidget.failed, widget.failed)) {
      oldWidget.failed?.removeListener(_onFailedChanged);
      widget.failed?.addListener(_onFailedChanged);
      if (oldWidget.failed?.value != widget.failed?.value) _onFailedChanged();
    }
  }

  @override
  void dispose() {
    for (final painter in _textPainters) painter.dispose();
    widget.verified?.removeListener(_onVerifiedChanged);
    widget.failed?.removeListener(_onFailedChanged);
    widget.controller.removeListener(_onTextChanged);
    _verificationAnimation.dispose();
    _failureAnimation.dispose();
    _previousText.dispose();
    _animation.dispose();
    _theme.dispose();
    super.dispose();
  }

  /// Animates typing, paste, and autofill without rebuilding the input subtree.
  void _onTextChanged() {
    if (_text == widget.controller.text) return;
    _previousText.value = _text;
    _text = widget.controller.text;
    if (!widget.enabled || MediaQuery.disableAnimationsOf(context)) {
      _animation.value = 1;
    } else {
      // Clearing uses a longer transition so the last digit can follow the first.
      _animation.duration = _text.isEmpty ? kThemeChangeDuration * 2 : kThemeChangeDuration;
      _animation.forward(from: 0);
    }
  }

  /// Starts a paint-only transition when the caller reports server acceptance.
  void _onVerifiedChanged() {
    if (widget.verified?.value == true) {
      // Repeated notifications of the accepted value must not report success twice.
      if (_verificationAnimation.isDismissed) _verificationAnimation.forward();
    } else {
      _verificationAnimation.value = 0;
    }
  }

  /// Animates a failed request once; clearing the caller's flag restores normal outlines.
  void _onFailedChanged() {
    if (widget.failed?.value == true) {
      if (_failureAnimation.isDismissed) _failureAnimation.forward();
    } else {
      _failureAnimation.value = 0;
    }
  }

  /// Lets the completed green frame reach the screen before navigation occurs.
  void _onVerificationStatusChanged(AnimationStatus status) {
    if (status != .completed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.verified?.value != true || !_verificationAnimation.isCompleted) return;
      widget.onVerified?.call();
    });
  }

  /// Retains paragraphs for existing cells and disposes those removed by a length change.
  void _updateTextPainters() {
    while (_textPainters.length < widget.length) {
      _textPainters.add(TextPainter(maxLines: 1));
    }
    while (_textPainters.length > widget.length) {
      _textPainters.removeLast().dispose();
    }
  }

  /// Uses the field's toolbar, including its lazy selection overlay and clipboard actions.
  void _showToolbar() {
    if (!widget.enabled) return;
    if (widget.focusNode.context?.findAncestorStateOfType<EditableTextState>() case EditableTextState state) {
      // Reopen through the SDK so repeated gestures leave the menu visible.
      state
        ..hideToolbar()
        ..toggleToolbar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = theme.uiTheme.size;
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final textStyle = (theme.textTheme.displayLarge ?? DefaultTextStyle.of(context).style).merge(widget.textStyle);
    final width =
        widget.length * size.button.small +
        (widget.length - 1) * size.offset.extraSmall +
        (widget.separatorIndex == null ? 0 : size.offset.small + size.offset.extraSmall);

    // Follow the scaled digit size while keeping the cursor inside its cell.
    final cursorHeight = math.max(
      0.0,
      math.min(textScaler.scale(textStyle.fontSize ?? size.icon.regular), size.button.medium - size.offset.extraSmall),
    );

    // Use the same cell mapping for primary and secondary pointer gestures.
    void onTapDown(TapDownDetails details) {
      if (!widget.enabled) return;
      widget.focusNode.requestFocus();
      if (context.findRenderObject() case final RenderBox renderBox when renderBox.size.width > 0) {
        final scale = math.min(1.0, renderBox.size.width / width);
        final left = textDirection == .rtl ? renderBox.size.width - width * scale : 0.0;
        final x = (details.localPosition.dx - left) / scale;
        var index = x >= width ? widget.length : 0;
        for (var cell = 1; cell < widget.length && index != widget.length; cell++) {
          if (x <
              _calculateCellLeftOffset(
                cell,
                size.button.small,
                size.offset.extraSmall,
                widget.separatorIndex,
                size.offset.small,
              )) {
            index = cell - 1;
            break;
          }
          index = cell;
        }
        widget.controller.selection = TextSelection.collapsed(offset: math.min(index, widget.controller.text.length));
      }
    }

    return SizedBox(
      height: size.button.medium,
      child: Stack(
        clipBehavior: .none,
        children: <Widget>[
          Positioned.fill(
            child: MergeSemantics(
              child: Semantics(
                label: widget.label,
                enabled: widget.enabled,
                child: AbsorbPointer(
                  child: TextField(
                    showCursor: false,
                    autocorrect: false,
                    enableSuggestions: false,
                    enabled: widget.enabled,
                    maxLength: widget.length,
                    autofocus: widget.autofocus,
                    focusNode: widget.focusNode,
                    controller: widget.controller,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Colors.transparent),
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    autofillHints: const <String>[AutofillHints.oneTimeCode],
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    // The SDK field owns editing and semantics; only the painter draws the cells.
                    decoration: const InputDecoration(
                      filled: false,
                      border: .none,
                      focusedBorder: .none,
                      enabledBorder: .none,
                      disabledBorder: .none,
                      counterText: '',
                      contentPadding: .zero,
                    ),
                    onChanged: widget.onChanged,
                    onSubmitted: (_) => widget.onSubmitted?.call(),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ExcludeSemantics(
              child: GestureDetector(
                onLongPressStart: (_) => _showToolbar(),
                onSecondaryTapDown: (details) {
                  onTapDown(details);
                  _showToolbar();
                },
                onTapDown: onTapDown,
                behavior: .opaque,
                child: FittedBox(
                  alignment: .centerStart,
                  fit: .scaleDown,
                  child: SizedBox(
                    height: size.button.medium,
                    width: width,
                    child: Stack(
                      clipBehavior: .none,
                      children: <Widget>[
                        // Extend only the paint viewport; cells keep their original layout origin.
                        Positioned.fill(
                          top: -size.offset.extraSmall,
                          left: -size.offset.extraSmall,
                          right: -size.offset.extraSmall,
                          bottom: -size.offset.extraSmall,
                          child: RepaintBoundary(
                            key: const ValueKey<String>('pin_input_painter'),
                            child: CustomPaint(
                              painter: _PinPainter(
                                theme: _theme,
                                animation: _animation,
                                previousText: _previousText,
                                length: widget.length,
                                enabled: widget.enabled,
                                focusNode: widget.focusNode,
                                controller: widget.controller,
                                separatorIndex: widget.separatorIndex,
                                failureAnimation: _failureAnimation,
                                failedColor: CupertinoDynamicColor.resolve(CupertinoColors.systemRed, context),
                                verificationAnimation: _verificationAnimation,
                                verifiedColor: CupertinoDynamicColor.resolve(CupertinoColors.systemGreen, context),
                                highContrast: MediaQuery.highContrastOf(context),
                                textStyle: textStyle,
                                textScaler: textScaler,
                                textPainters: _textPainters,
                                textDirection: textDirection,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: ListenableBuilder(
                            listenable: Listenable.merge(<Listenable>[widget.controller, widget.focusNode]),
                            builder: (context, _) {
                              final code = widget.controller.text;
                              final selection = widget.controller.selection.extentOffset;
                              final activeIndex = (selection < 0 ? code.length : selection).clamp(0, widget.length - 1);
                              if (widget.enabled &&
                                  widget.focusNode.hasFocus &&
                                  activeIndex == code.length &&
                                  code.length < widget.length) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Transform.translate(
                                    offset: Offset(
                                      _calculateCellLeftOffset(
                                            activeIndex,
                                            size.button.small,
                                            size.offset.extraSmall,
                                            widget.separatorIndex,
                                            size.offset.small,
                                          ) +
                                          (size.button.small - size.offset.extraExtraSmall) / 2,
                                      (size.button.medium - cursorHeight) / 2,
                                    ),
                                    child: _BlinkingPinCursor(color: theme.uiTheme.color.text, height: cursorHeight),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Includes the extra gap occupied by the divider when it precedes [index].
double _calculateCellLeftOffset(int index, double width, double spacing, int? separatorIndex, double separatorWidth) =>
    index * (width + spacing) + (separatorIndex != null && index >= separatorIndex ? separatorWidth + spacing : 0);

/// Scales a digit down only when it would extend beyond its cell and border.
double _pinTextScale(Size textSize, Size cellSize) {
  if (textSize.isEmpty) return 1;
  final border = const BorderSide().width * 2;
  return math.min(
    1,
    math.min((cellSize.width - border) / textSize.width, (cellSize.height - border) / textSize.height),
  );
}

/// Paints code cells from the current text, focus, and theme values.
class _PinPainter extends CustomPainter {
  /// Subscribes the painter to the mutable values it reads during [paint].
  ///
  /// [controller] supplies digits and selection; [focusNode] identifies the
  /// active cell when [enabled]. [length] sets the number of cells, and
  /// [separatorIndex] inserts a visual divider. [theme] supplies cell dimensions,
  /// spacing, corners, and colors. [highContrast] increases outline width.
  ///
  /// [animation] scales digits that differ from [previousText] and rolls removed
  /// digits out of their cells. Clearing all digits staggers their exit.
  /// [verificationAnimation] blends cell outlines toward [verifiedColor], which
  /// must already be resolved for the platform's brightness and contrast, and
  /// pulses the cells within their reserved padding before settling.
  /// [failureAnimation] shakes cells and blends outlines toward the resolved
  /// [failedColor]. Both transforms finish at the original cell positions.
  /// Verified styling takes precedence. Animation values range from zero to one.
  ///
  /// [textStyle], [textScaler], and [textDirection] configure glyph layout.
  /// [textPainters] contains at least [length] cached paragraphs. The input state
  /// disposes the paragraphs and animations; text controllers and focus nodes
  /// remain owned by the caller. This delegate borrows the supplied objects and
  /// subscribes only for repaint notifications.
  _PinPainter({
    required this.length,
    required this.focusNode,
    required this.controller,
    required this.enabled,
    required this.animation,
    required this.verificationAnimation,
    required this.verifiedColor,
    required this.failureAnimation,
    required this.failedColor,
    required this.previousText,
    required this.highContrast,
    required this.separatorIndex,
    required this.theme,
    required this.textStyle,
    required this.textScaler,
    required this.textDirection,
    required this.textPainters,
  }) : super(
         repaint: Listenable.merge(<Listenable>[
           theme,
           animation,
           focusNode,
           controller,
           previousText,
           verificationAnimation,
           failureAnimation,
         ]),
       );

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool highContrast;
  final bool enabled;

  /// SDK animation values repaint the canvas without a widget builder.
  final Animation<double> animation;

  /// Platform error color resolved outside paint for theme and contrast changes.
  final Color failedColor;

  /// Progress through the failed-request shake and red outlines.
  final Animation<double> failureAnimation;

  /// Platform success color resolved outside paint for theme and contrast changes.
  final Color verifiedColor;

  /// Progress through the server-confirmed pulse, green outlines, and settled frame.
  final Animation<double> verificationAnimation;

  /// Text before the current animation, used to leave unchanged digits stationary.
  final ValueListenable<String> previousText;

  /// Total number of digits expected in the input.
  final int length;

  /// Index at which to place a visual separator between cell groups, if any.
  final int? separatorIndex;

  /// Whether to use high contrast colors for accessibility.
  final TextStyle textStyle;

  /// Text scaling factor for accessibility.
  final TextScaler textScaler;

  /// Text direction for the input, used for proper layout and painting.
  final TextDirection textDirection;

  /// Borrowed from the input state; this delegate does not dispose it.
  final List<TextPainter> textPainters;

  /// The state owns this listenable and disposes it after the painter is removed.
  final ValueListenable<ThemeData> theme;

  /// Reused for cell outlines and the divider.
  final Paint _stroke = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = const BorderSide().width;

  /// Colors from the current theme value, including changes since construction.
  UIColors get colors => theme.value.uiTheme.color;

  /// Sizes from the current theme value, including changes since construction.
  UISizes get sizes => theme.value.uiTheme.size;

  /// Corner radius from the shared control size scale.
  double get borderRadius => sizes.corner.regular;

  /// Width reserved for a visual divider between cell groups.
  double get separatorWidth => sizes.offset.small;

  /// Gap between adjacent digit cells.
  double get spacing => sizes.offset.extraSmall;

  /// Height of a digit cell in the current theme.
  double get cellHeight => sizes.button.medium;

  /// Width of a digit cell in the current theme.
  double get cellWidth => sizes.button.small;

  /// Latest code from the caller-owned text controller.
  String get code => controller.text;

  /// Selection position clamped to the painted cells, falling back to code length.
  int get activeIndex {
    final selection = controller.selection.extentOffset;
    return (selection < 0 ? code.length : selection).clamp(0, length - 1);
  }

  /// Damped horizontal motion; endpoints and accepted codes keep their cells still.
  double get failureOffset =>
      failureAnimation.value > 0 && failureAnimation.value < 1 && verificationAnimation.value == 0
      ? math.sin(failureAnimation.value * math.pi * 6) * spacing * (1 - failureAnimation.value)
      : 0;

  /// Staggers a full clear across half the transition; each digit rolls out locally.
  double removalProgress(int index) =>
      code.isEmpty ? ((animation.value - index / length / 2) * 2).clamp(0.0, 1.0) : animation.value;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    // Clip all cells to the assigned bounds and restore the canvas in finally.
    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    try {
      // Limit the pulse to the reserved padding, including long codes and narrow cells.
      final pulse = const Interval(0, 2 / 3).transform(verificationAnimation.value);
      final scale =
          1.0 +
          (pulse > 0 && pulse < 1 ? math.sin(pulse * math.pi) : 0.0) *
              math.min(0.08, spacing * 2 / math.max(size.width - spacing * 2, size.height - spacing * 2));
      canvas
        ..translate(size.width / 2, size.height / 2)
        ..scale(scale)
        ..translate(-size.width / 2 + failureOffset, -size.height / 2);
      for (var index = 0; index < length; index++) {
        final left = spacing + _calculateCellLeftOffset(index, cellWidth, spacing, separatorIndex, separatorWidth);
        final isFocused = enabled && focusNode.hasFocus && index == activeIndex;
        final rect = Rect.fromLTWH(left, spacing, cellWidth, cellHeight);
        final borderWidth =
            const BorderSide().width *
            (highContrast || isFocused || verificationAnimation.value > 0 || failureAnimation.value > 0 ? 2 : 1);
        // Inset the stroke so its outer edge stays inside the cell even when focused.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.deflate(borderWidth / 2),
            .circular(math.max(0, borderRadius - borderWidth / 2)),
          ),
          _stroke
            ..color =
                Color.lerp(
                  Color.lerp(
                    isFocused ? colors.accent : colors.border,
                    failedColor,
                    const Interval(0, 0.5, curve: Curves.easeOut).transform(failureAnimation.value),
                  ),
                  verifiedColor,
                  const Interval(0, 1 / 3, curve: Curves.easeOut).transform(verificationAnimation.value),
                ) ??
                verifiedColor
            ..strokeWidth = borderWidth,
        );
        if (index < code.length || index < previousText.value.length && removalProgress(index) < 1) {
          final removing = index >= code.length;
          final textPainter = textPainters[index]
            ..textDirection = textDirection
            ..textScaler = textScaler
            ..text = TextSpan(
              text: removing ? previousText.value[index] : code[index],
              style: textStyle.copyWith(color: isFocused ? colors.textSecondary : colors.text),
            )
            ..layout();
          final scale =
              _pinTextScale(textPainter.size, Size(cellWidth, cellHeight)) *
              (!removing && (index >= previousText.value.length || code[index] != previousText.value[index])
                  ? Curves.easeOutCubic.transform(animation.value)
                  : 1);
          // Clip rolling digits within their own cells; cached paragraphs need no fade layer.
          canvas
            ..save()
            ..clipRect(rect.deflate(borderWidth))
            ..translate(
              left + cellWidth / 2,
              spacing +
                  cellHeight / 2 +
                  (removing ? cellHeight * Curves.easeInCubic.transform(removalProgress(index)) : 0),
            )
            ..scale(scale);
          try {
            textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
          } finally {
            canvas.restore();
          }
        }
      }
      if (separatorIndex case final int index) {
        final left = spacing + index * (cellWidth + spacing);
        final center = Offset(left + separatorWidth / 2, spacing + cellHeight / 2);
        canvas.drawLine(
          Offset(center.dx - separatorWidth / 4, center.dy),
          Offset(center.dx + separatorWidth / 4, center.dy),
          _stroke
            ..color = colors.textSecondary
            ..strokeWidth = const BorderSide().width,
        );
      }
    } finally {
      canvas.restore();
    }
  }

  /// Repaints for replaced inputs; mutations are handled by the merged listenable.
  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) =>
      oldDelegate.theme != theme ||
      oldDelegate.length != length ||
      oldDelegate.enabled != enabled ||
      oldDelegate.animation != animation ||
      oldDelegate.focusNode != focusNode ||
      oldDelegate.controller != controller ||
      oldDelegate.verifiedColor != verifiedColor ||
      oldDelegate.verificationAnimation != verificationAnimation ||
      oldDelegate.failedColor != failedColor ||
      oldDelegate.failureAnimation != failureAnimation ||
      oldDelegate.previousText != previousText ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.separatorIndex != separatorIndex ||
      oldDelegate.textStyle != textStyle ||
      oldDelegate.textScaler != textScaler ||
      oldDelegate.textDirection != textDirection;
}

/// Blinks the active cell cursor independently of the painted code cells.
///
/// Reduced motion keeps the cursor visible and stops its timer.
class _BlinkingPinCursor extends StatefulWidget {
  /// Creates a cursor with [color] and [height] in logical pixels.
  ///
  /// Its width follows the theme's smallest spacing token. Blinking follows
  /// [TickerMode] and [MediaQueryData.disableAnimations].
  const _BlinkingPinCursor({required this.color, required this.height});

  final double height;
  final Color color;

  @override
  State<_BlinkingPinCursor> createState() => _BlinkingPinCursorState();
}

/// State for the [_BlinkingPinCursor] widget.
class _BlinkingPinCursorState extends State<_BlinkingPinCursor> {
  bool _visible = true;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Stop blinking for reduced motion or an inactive subtree, keeping the cursor visible.
    if (!MediaQuery.disableAnimationsOf(context) && TickerMode.valuesOf(context).enabled) {
      _timer ??= Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted) setState(() => _visible = !_visible);
      });
    } else {
      _timer?.cancel();
      _visible = true;
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: _visible ? 1 : 0,
    child: SizedBox(
      height: widget.height,
      child: VerticalDivider(width: Theme.of(context).uiTheme.size.offset.extraExtraSmall, color: widget.color),
    ),
  );
}
