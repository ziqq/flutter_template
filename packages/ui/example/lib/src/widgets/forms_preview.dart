import 'package:example/src/common/widgets/preview_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

/// Demonstrates list rows and a dismissible, keyboard-accessible flyout.
class FormsPreview extends StatelessWidget {
  const FormsPreview({super.key});

  @override
  Widget build(BuildContext context) => const PreviewSection(
    title: 'Lists and flyout',
    child: Column(children: [_BooleanRows(), _SelectionRow()]),
  );
}

class _BooleanRows extends StatefulWidget {
  const _BooleanRows();

  @override
  State<_BooleanRows> createState() => _BooleanRowsState();
}

class _BooleanRowsState extends State<_BooleanRows> {
  bool _value = true;

  @override
  Widget build(BuildContext context) => UIListSection(
    children: [
      UIListTile(
        title: const Text('Enabled'),
        trailing: UISwitch(value: _value, onChanged: (value) => setState(() => _value = value)),
      ),
      UIListTile(
        title: const Text('Rounded checkbox'),
        leading: Semantics(
          checked: _value,
          child: UICheckBoxRounded(isChecked: _value, disable: true),
        ),
        onTap: () => setState(() => _value = !_value),
      ),
      const UIListTile(title: Text('Saving (disabled)'), enabled: false, trailing: UILoaderIndicator()),
    ],
  );
}

class _SelectionRow extends StatefulWidget {
  const _SelectionRow();

  @override
  State<_SelectionRow> createState() => _SelectionRowState();
}

class _SelectionRowState extends State<_SelectionRow> {
  String _selection = 'System';
  bool _open = false;

  void _dismiss() => setState(() => _open = false);

  @override
  Widget build(BuildContext context) => UIFlyout(
    isOpen: _open,
    width: UIFlyoutWidth.fill,
    anchor: const UIFlyoutAnchor(offset: Offset(0, 4)),
    backdropBuilder: (context, _) => ModalBarrier(
      dismissible: true,
      onDismiss: _dismiss,
      semanticsLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    ),
    flyoutBuilder: (context, _) => FocusScope(
      autofocus: true,
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): _dismiss},
        child: Material(
          elevation: 4,
          borderRadius: UIBorderRadius.regular(context),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final value in const ['System', 'Light', 'Dark'])
                TextButton(
                  autofocus: value == _selection,
                  onPressed: () => setState(() {
                    _selection = value;
                    _open = false;
                  }),
                  child: Row(
                    children: [
                      Expanded(child: Text(value)),
                      if (value == _selection) const Icon(CupertinoIcons.check_mark),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    child: UIListTile(
      title: const Text('Selection'),
      additionalInfo: Text(_selection),
      onTap: () => setState(() => _open = !_open),
    ),
  );
}
