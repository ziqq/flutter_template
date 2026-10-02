import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/material.dart';
import 'package:ui/src/components/inputs/text_input.dart';
import 'package:ui/src/localization/localization.dart';

/// An SDK form field with a keyboard-accessible password visibility action.
/// The caller owns an optional [controller] and [focusNode].
class UIPasswordInput extends StatefulWidget {
  const UIPasswordInput({
    this.labelText,
    this.controller,
    this.focusNode,
    this.order,
    this.validator,
    this.errorText,
    this.helperText,
    this.backgroundColor,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autofillHints = const [AutofillHints.password],
    super.key,
  });

  final String? labelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? order;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final String? helperText;
  final Color? backgroundColor;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  State<UIPasswordInput> createState() => _UIPasswordInputState();
}

class _UIPasswordInputState extends State<UIPasswordInput> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = UILocalizations.of(context);
    final child = UITextInput(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      labelText: widget.labelText,
      errorText: widget.errorText,
      helperText: widget.helperText,
      validator: widget.validator,
      backgroundColor: widget.backgroundColor,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: !_visible,
      keyboardType: TextInputType.visiblePassword,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: widget.autofillHints,
      suffixIcon: IconButton(
        iconSize: 22,
        color: CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(color: Color(0x33000000), darkColor: Color(0x33FFFFFF)),
          context,
        ),
        tooltip: _visible ? l10n.hidePasswordButton : l10n.showPasswordButton,
        isSelected: _visible,
        onPressed: widget.enabled ? () => setState(() => _visible = !_visible) : null,
        icon: const Icon(Icons.visibility),
        selectedIcon: const Icon(Icons.visibility_off),
      ),
    );
    return widget.order == null ? child : FocusTraversalOrder(order: NumericFocusOrder(widget.order!), child: child);
  }
}
