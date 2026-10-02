import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:ui/ui.dart';

/// Formats a caller-owned selection option.
typedef UISelectOptionToString<T extends Object> = String Function(T option);

/// A generic form selection with an SDK dropdown or a Cupertino confirmation picker.
///
/// Options use `==`. Supply either [value] or a caller-owned [controller]. The
/// controller is never disposed; form reset restores the initial selection.
class UISelect<T extends Object> extends FormField<T> {
  UISelect({
    required this.items,
    required this.displayStringForOption,
    this.controller,
    this.value,
    this.title,
    this.width,
    this.labelText,
    this.errorText,
    this.onClearTap,
    this.onChanged,
    this.borderColor,
    this.backgroundColor,
    this.withoutBorder = false,
    super.validator,
    super.onSaved,
    super.onReset,
    super.autovalidateMode,
    super.enabled,
    super.key,
  }) : assert(controller == null || value == null, 'Provide either value or controller.'),
       super(initialValue: controller?.value ?? value, builder: (state) => (state as _UISelectState<T>)._buildField());

  final List<T> items;
  final UISelectOptionToString<T> displayStringForOption;
  final ValueNotifier<T?>? controller;
  final T? value;
  final String? title;
  final double? width;
  final String? labelText;
  final String? errorText;
  final VoidCallback? onClearTap;
  final ValueChanged<T?>? onChanged;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool withoutBorder;

  @override
  FormFieldState<T> createState() => _UISelectState<T>();
}

class _UISelectState<T extends Object> extends FormFieldState<T> {
  @override
  UISelect<T> get widget => super.widget as UISelect<T>;

  T? _resetValue;

  T? _normalize(T? option) {
    final index = option == null ? -1 : widget.items.indexOf(option);
    return index < 0 ? null : widget.items[index];
  }

  @override
  void initState() {
    super.initState();
    _resetValue = value;
    setValue(_normalize(value));
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UISelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
    if (oldWidget.controller != widget.controller || oldWidget.value != widget.value) {
      _resetValue = widget.controller == null ? widget.value : widget.controller!.value;
      setValue(_normalize(_resetValue));
    } else if (oldWidget.items != widget.items) {
      setValue(_normalize(widget.controller == null ? value : widget.controller!.value));
    }
  }

  void _onControllerChanged() {
    final selected = _normalize(widget.controller?.value);
    if (selected != value) didChange(selected);
  }

  void _select(T? selected) {
    final normalized = _normalize(selected);
    didChange(normalized);
    widget.controller?.value = normalized;
    widget.onChanged?.call(normalized);
  }

  @override
  void reset() {
    super.reset();
    final initial = _normalize(_resetValue);
    setState(() => setValue(initial));
    widget.controller?.value = initial;
    widget.onChanged?.call(initial);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  Future<void> _openPicker() async {
    if (!widget.enabled || widget.items.isEmpty) return;
    final options = List<T>.of(widget.items);
    var index = value == null ? 0 : options.indexOf(value as T);
    if (index < 0) index = 0;
    final controller = FixedExtentScrollController(initialItem: index);
    T? selected;
    try {
      selected = await UI.showModalBottomSheet<T>(
        context: context,
        useSafeArea: true,
        builder: (context) {
          final strings = UILocalizations.of(context);
          return SizedBox(
            height: 300,
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.cancelButton)),
                    Expanded(
                      child: Text(widget.title ?? widget.labelText ?? strings.selectLabel, textAlign: TextAlign.center),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(options[index]),
                      child: Text(strings.doneButton),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: controller,
                    itemExtent: Theme.of(context).uiTheme.size.button.small,
                    onSelectedItemChanged: (selectedIndex) => index = selectedIndex,
                    children: [
                      for (final option in options) Center(child: Text(widget.displayStringForOption(option))),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      controller.dispose();
    }
    if (mounted && widget.enabled && selected != null && widget.items.contains(selected)) _select(selected);
  }

  Widget _buildField() {
    final theme = Theme.of(context);
    final ui = theme.uiTheme;
    final border = OutlineInputBorder(
      borderRadius: UIBorderRadius.regular(context),
      borderSide: widget.withoutBorder ? BorderSide.none : BorderSide(color: widget.borderColor ?? ui.color.border),
    );
    final desktop =
        kIsWeb ||
        switch (defaultTargetPlatform) {
          TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => true,
          _ => false,
        };
    return SizedBox(
      width: widget.width,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              label: widget.labelText ?? widget.title ?? UILocalizations.of(context).selectLabel,
              value: value == null ? null : widget.displayStringForOption(value as T),
              child: desktop
                  ? DropdownMenu<T>(
                      key: ValueKey<T?>(value),
                      initialSelection: value,
                      enabled: widget.enabled && widget.items.isNotEmpty,
                      expandedInsets: EdgeInsets.zero,
                      selectOnly: true,
                      enableSearch: false,
                      requestFocusOnTap: true,
                      label: widget.labelText == null ? null : Text(widget.labelText!),
                      errorText: widget.errorText ?? errorText,
                      inputDecorationTheme: InputDecorationThemeData(
                        filled: true,
                        fillColor: widget.backgroundColor ?? ui.color.surface,
                        border: border,
                        enabledBorder: border,
                      ),
                      dropdownMenuEntries: [
                        for (final option in widget.items)
                          DropdownMenuEntry<T>(value: option, label: widget.displayStringForOption(option)),
                      ],
                      onSelected: _select,
                    )
                  : InkWell(
                      onTap: widget.enabled && widget.items.isNotEmpty ? _openPicker : null,
                      borderRadius: UIBorderRadius.regular(context),
                      child: InputDecorator(
                        isEmpty: value == null,
                        decoration: InputDecoration(
                          labelText: widget.labelText,
                          errorText: widget.errorText ?? errorText,
                          enabled: widget.enabled,
                          filled: true,
                          fillColor: widget.backgroundColor ?? ui.color.surface,
                          border: border,
                          enabledBorder: border,
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(value == null ? '' : widget.displayStringForOption(value as T)),
                      ),
                    ),
            ),
          ),
          if (value != null)
            IconButton(
              tooltip: UILocalizations.of(context).clearLabel,
              onPressed: widget.enabled
                  ? () {
                      _select(null);
                      widget.onClearTap?.call();
                    }
                  : null,
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }
}
