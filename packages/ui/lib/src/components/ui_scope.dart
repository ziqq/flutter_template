import 'package:flutter/widgets.dart';
import 'package:ui/src/components/operation_status_messenger.dart';

/// Installs the shared presentation host above the application's navigator.
///
/// Place this in MaterialApp.builder. Route-owned controllers and loading
/// scopes remain beside the feature that owns them.
class UIScope extends StatelessWidget {
  const UIScope({
    required this.child,
    this.operationStatusIndicatorStyle = UIOperationStatusIndicatorStyle.standard,
    super.key,
  });

  final Widget child;
  final UIOperationStatusIndicatorStyle operationStatusIndicatorStyle;

  @override
  Widget build(BuildContext context) =>
      UIOperationStatusMessenger(indicatorStyle: operationStatusIndicatorStyle, child: child);
}
