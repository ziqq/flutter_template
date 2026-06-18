// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

/// {@template custom_switch}
/// UISwitch widget.
/// {@endtemplate}
class UISwitch extends StatelessWidget {
  /// {@macro custom_switch}
  const UISwitch({required this.value, this.loading = false, this.onChanged, super.key});

  /// The current value of the switch.
  final bool value;

  /// Whether the switch is in loading state.
  final bool loading;

  /// Called when the user toggles the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Transform(
    transform: Matrix4.translationValues(loading ? 0 : 4, 0, 0),
    child: loading
        ? ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 57),
            child: const Padding(
              padding: .only(right: 5),
              child: Align(alignment: Alignment.centerRight, child: UILoaderIndicator(adaptive: false)),
            ),
          )
        : CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: CupertinoDynamicColor.resolve(CupertinoColors.systemGreen, context),
          ),
  );
}
