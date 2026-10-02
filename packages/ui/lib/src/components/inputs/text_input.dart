import 'package:flutter/cupertino.dart' show CupertinoDynamicColor, CupertinoIcons, CupertinoLocalizations;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/src/components/border_radius.dart';
import 'package:ui/src/theme/theme.dart';

/// A themed SDK form field with an optional clear action.
///
/// External controllers and focus nodes remain caller-owned. [initialValue]
/// initializes an internally owned controller and is restored by Form.reset;
/// later changes do not overwrite edits. Use [controller] for controlled text.
/// [height] is a minimum: labels, errors and scaled text can grow vertically.
class UITextInput extends StatefulWidget {
  const UITextInput({
    this.controller,
    this.focusNode,
    this.initialValue,
    this.displayText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.withoutBorder = false,
    this.width,
    this.height = minHeight,
    this.bottomOffset = offset,
    this.cursorHeight,
    this.borderRadius,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.hintText,
    this.labelText,
    this.errorText,
    this.helperText,
    this.prefixText,
    this.counterText,
    this.counterTextColor,
    this.style,
    this.hintStyle,
    this.borderColor,
    this.backgroundColor,
    this.suffixIcon,
    this.prefixIcon,
    this.suffixIconConstraints,
    this.margin,
    this.padding,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.autofillHints,
    this.autovalidateMode,
    this.restorationId,
    this.onChanged,
    this.onTap,
    this.onClearTap,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    super.key,
  }) : assert(controller == null || initialValue == null, 'controller and initialValue are mutually exclusive.'),
       assert(displayText == null || readOnly, 'displayText requires readOnly.'),
       assert(displayText == null || controller == null && initialValue == null, 'displayText owns its text.'),
       assert(height > 0 && height < double.infinity, 'Minimum height must be positive and finite.'),
       assert(!obscureText || maxLines == 1, 'Obscured fields must use one line.');

  /// Creates a field without the default bottom spacing.
  const factory UITextInput.offsetless({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? initialValue,
    String? displayText,
    bool enabled,
    bool readOnly,
    bool autofocus,
    bool obscureText,
    bool autocorrect,
    bool enableSuggestions,
    bool withoutBorder,
    double? width,
    double height,
    double? cursorHeight,
    BorderRadius? borderRadius,
    int? maxLines,
    int? minLines,
    int? maxLength,
    String? hintText,
    String? labelText,
    String? errorText,
    String? helperText,
    String? prefixText,
    String? counterText,
    Color? counterTextColor,
    TextStyle? style,
    TextStyle? hintStyle,
    Color? borderColor,
    Color? backgroundColor,
    Widget? suffixIcon,
    Widget? prefixIcon,
    BoxConstraints? suffixIconConstraints,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    String? restorationId,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    VoidCallback? onClearTap,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    Key? key,
  }) = _OffsetlessTextInput;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final String? displayText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool withoutBorder;
  final double? width;
  final double height;
  final double? bottomOffset;
  final double? cursorHeight;
  final BorderRadius? borderRadius;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final String? helperText;
  final String? prefixText;
  final String? counterText;
  final Color? counterTextColor;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final Color? borderColor;
  final Color? backgroundColor;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final BoxConstraints? suffixIconConstraints;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final String? restorationId;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClearTap;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;

  static const double minHeight = 56;
  static const double offset = 25;

  @override
  State<UITextInput> createState() => _UITextInputState();
}

class _UITextInputState extends State<UITextInput> with RestorationMixin {
  RestorableTextEditingController? _localController;
  late bool _hasText;

  TextEditingController get _controller => widget.controller ?? _localController!.value;

  Listenable get _textListenable => widget.controller ?? _localController!;

  @override
  String? get restorationId => widget.restorationId;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _localController = RestorableTextEditingController(text: widget.displayText ?? widget.initialValue);
    }
    _hasText = (widget.controller?.text ?? widget.displayText ?? widget.initialValue ?? '').isNotEmpty;
    _textListenable.addListener(_handleTextChanged);
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_localController != null) registerForRestoration(_localController!, 'controller');
    if (widget.displayText != null) _controller.text = widget.displayText!;
    setState(() => _hasText = _controller.text.isNotEmpty);
  }

  @override
  void didUpdateWidget(covariant UITextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final previous = oldWidget.controller ?? _localController!.value;
      (oldWidget.controller ?? _localController!).removeListener(_handleTextChanged);
      if (widget.controller == null) {
        _localController = RestorableTextEditingController.fromValue(previous.value);
        if (!restorePending) registerForRestoration(_localController!, 'controller');
      } else if (_localController != null) {
        final owned = _localController!;
        unregisterFromRestoration(owned);
        _localController = null;
        WidgetsBinding.instance.addPostFrameCallback((_) => owned.dispose());
      }
      _textListenable.addListener(_handleTextChanged);
    }
    if (!restorePending && widget.displayText != null && widget.displayText != oldWidget.displayText) {
      _controller.text = widget.displayText!;
    }
    if (!restorePending) _hasText = _controller.text.isNotEmpty;
  }

  void _handleTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText == hasText) return;
    setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _textListenable.removeListener(_handleTextChanged);
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiTheme = theme.uiTheme;
    final desktop = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia => false,
      _ => true,
    };
    final border = OutlineInputBorder(
      borderRadius: widget.borderRadius ?? UIBorderRadius.regular(context),
      borderSide: widget.withoutBorder
          ? BorderSide.none
          : BorderSide(
              color:
                  widget.borderColor ??
                  (theme.brightness == Brightness.dark ? uiTheme.color.surface : theme.dividerColor),
              width: 2,
            ),
    );
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.bottomOffset ?? UITextInput.offset),
        child: SizedBox(
          width: widget.width,
          child: TextFormField(
            controller: _controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            obscureText: widget.obscureText,
            autocorrect: widget.autocorrect,
            enableSuggestions: widget.enableSuggestions,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            cursorHeight: widget.cursorHeight,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            autofillHints: widget.autofillHints,
            autovalidateMode: widget.autovalidateMode,
            restorationId: widget.restorationId,
            style:
                widget.style ??
                theme.textTheme.bodyLarge?.copyWith(
                  height: 1.1,
                  color: widget.enabled ? uiTheme.color.text : uiTheme.color.textSecondary,
                ),
            cursorColor: uiTheme.color.text,
            textAlignVertical: widget.labelText == null && widget.maxLines == 1 ? TextAlignVertical.center : null,
            forceErrorText: widget.errorText,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onFieldSubmitted,
            onSaved: widget.onSaved,
            validator: widget.validator,
            decoration: InputDecoration(
              constraints: BoxConstraints(minHeight: widget.height),
              isDense: true,
              visualDensity: VisualDensity.standard,
              alignLabelWithHint: widget.maxLines != 1,
              contentPadding:
                  widget.padding ??
                  EdgeInsets.only(
                    left: uiTheme.size.offset.regular,
                    right: uiTheme.size.offset.regular,
                    top: desktop || kIsWeb ? uiTheme.size.offset.regular : uiTheme.size.offset.small,
                    bottom: desktop || kIsWeb ? uiTheme.size.offset.regular : 0,
                  ),
              filled: true,
              fillColor: widget.backgroundColor ?? (widget.enabled ? uiTheme.color.surface : uiTheme.color.disabled),
              labelText: widget.labelText,
              labelStyle: theme.textTheme.bodyLarge?.copyWith(height: 1, color: uiTheme.color.textSecondary),
              hintText: widget.hintText,
              hintStyle:
                  widget.hintStyle ?? TextStyle(height: 1, color: uiTheme.color.textSecondary.withValues(alpha: 0.55)),
              helperText: widget.helperText,
              helperStyle: theme.textTheme.labelSmall?.copyWith(fontSize: 12, color: uiTheme.color.textSecondary),
              errorStyle: theme.textTheme.labelSmall?.copyWith(fontSize: 12, color: theme.colorScheme.error),
              helperMaxLines: 3,
              errorMaxLines: 3,
              prefixText: widget.prefixText,
              prefixStyle: theme.textTheme.bodyLarge?.copyWith(color: uiTheme.color.textSecondary),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon ?? _clearButton(context),
              suffixIconConstraints: widget.suffixIconConstraints,
              counterText: widget.counterText,
              counterStyle: theme.textTheme.labelSmall?.copyWith(color: widget.counterTextColor),
              border: border,
              enabledBorder: border,
              disabledBorder: widget.withoutBorder
                  ? border
                  : border.copyWith(borderSide: BorderSide(color: uiTheme.color.disabled, width: 2)),
              focusedBorder: border,
              errorBorder: widget.withoutBorder
                  ? border
                  : border.copyWith(borderSide: BorderSide(color: theme.colorScheme.error, width: 2)),
              focusedErrorBorder: widget.withoutBorder
                  ? border
                  : border.copyWith(borderSide: BorderSide(color: theme.colorScheme.error, width: 2)),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _clearButton(BuildContext context) {
    if (!widget.enabled || widget.readOnly || !_hasText) return null;
    return IconButton(
      tooltip: CupertinoLocalizations.of(context).clearButtonLabel,
      iconSize: Theme.of(context).uiTheme.size.icon.small,
      color: CupertinoDynamicColor.resolve(
        const CupertinoDynamicColor.withBrightness(color: Color(0x33000000), darkColor: Color(0x33FFFFFF)),
        context,
      ),
      onPressed: () {
        _controller.clear();
        widget.onChanged?.call('');
        widget.onClearTap?.call();
      },
      icon: const Icon(CupertinoIcons.clear_thick_circled),
    );
  }
}

class _OffsetlessTextInput extends UITextInput {
  const _OffsetlessTextInput({
    super.controller,
    super.focusNode,
    super.initialValue,
    super.displayText,
    super.enabled,
    super.readOnly,
    super.autofocus,
    super.obscureText,
    super.autocorrect,
    super.enableSuggestions,
    super.withoutBorder,
    super.width,
    super.height,
    super.cursorHeight,
    super.borderRadius,
    super.maxLines,
    super.minLines,
    super.maxLength,
    super.hintText,
    super.labelText,
    super.errorText,
    super.helperText,
    super.prefixText,
    super.counterText,
    super.counterTextColor,
    super.style,
    super.hintStyle,
    super.borderColor,
    super.backgroundColor,
    super.suffixIcon,
    super.prefixIcon,
    super.suffixIconConstraints,
    super.margin,
    super.padding,
    super.keyboardType,
    super.textInputAction,
    super.textCapitalization,
    super.inputFormatters,
    super.autofillHints,
    super.autovalidateMode,
    super.restorationId,
    super.onChanged,
    super.onTap,
    super.onClearTap,
    super.onFieldSubmitted,
    super.onSaved,
    super.validator,
    super.key,
  }) : super(bottomOffset: 0);
}
