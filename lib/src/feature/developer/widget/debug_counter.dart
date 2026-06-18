import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// {@template debug_counter}
/// DebugCounter widget.
///
/// Display the current count and total count.
/// Usually used in [AppBar] title.
/// {@endtemplate}
class DebugCounter extends StatelessWidget {
  /// {@macro debug_counter}
  const DebugCounter({
    this.count,
    this.total,
    super.key, // ignore: unused_element_parameter
  });

  final int? count;
  final int? total;

  @override
  Widget build(BuildContext context) => count == null
      ? const SizedBox.shrink()
      : DecoratedBox(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemFill, context),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Text(
              '$count${total != null ? ' / $total' : ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        );
}
