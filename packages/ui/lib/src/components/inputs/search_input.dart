import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons, CupertinoSearchTextField;
import 'package:flutter/material.dart';
import 'package:ui/src/components/border_radius.dart';
import 'package:ui/src/components/loader_indicator.dart';
import 'package:ui/src/theme/theme.dart';

/// A Cupertino search field whose clear action always clears the query.
/// [onSuffixTap] observes that action after clearing; it does not replace it.
class UISearchInput extends StatefulWidget {
  const UISearchInput({
    this.controller,
    this.focusNode,
    this.placeholder,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onSuffixTap,
    this.backgroundColor,
    this.order,
    this.loading = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.enabled = true,
    super.key,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSuffixTap;
  final Color? backgroundColor;
  final double? order;
  final bool loading;
  final bool autofocus;
  final bool autocorrect;
  final bool enabled;

  @override
  State<UISearchInput> createState() => _UISearchInputState();
}

class _UISearchInputState extends State<UISearchInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant UISearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      final previous = _controller;
      _controller = widget.controller ?? TextEditingController.fromValue(previous.value);
      if (oldWidget.controller == null) scheduleMicrotask(previous.dispose);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _clear() {
    if (!widget.enabled) return;
    final changed = _controller.text.isNotEmpty;
    _controller.clear();
    if (changed) widget.onChanged?.call('');
    widget.onSuffixTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = CupertinoSearchTextField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      placeholder: widget.placeholder,
      backgroundColor: widget.backgroundColor,
      borderRadius: UIBorderRadius.regular(context),
      suffixInsets: const EdgeInsetsDirectional.only(end: 5),
      prefixIcon: widget.loading
          ? Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: UILoaderIndicator(radius: 8, strokeWidth: 2, color: theme.uiTheme.color.textSecondary),
            )
          : Icon(CupertinoIcons.search, color: theme.uiTheme.color.textSecondary),
      style: theme.textTheme.bodyLarge?.copyWith(height: 1.2),
      placeholderStyle: theme.textTheme.bodyLarge?.copyWith(
        height: 1.2,
        color: theme.uiTheme.color.textSecondary.withValues(alpha: .5),
      ),
      onSuffixTap: _clear,
    );
    return widget.order == null ? child : FocusTraversalOrder(order: NumericFocusOrder(widget.order!), child: child);
  }
}
