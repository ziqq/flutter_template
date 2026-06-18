import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/common/util/shake_detector.dart';
import 'package:flutter_template_name/src/feature/bug_report/widget/bug_report_dialog.dart';

/// {@template bug_report_scope}
/// BugReportScope widget.
/// {@endtemplate}
class BugReportScope extends StatefulWidget {
  /// {@macro bug_report_scope}
  const BugReportScope({
    required this.child,
    super.key, // ignore: unused_element
  });

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  State<BugReportScope> createState() => _BugReportScopeState();
}

/// State for widget [BugReportScope].
class _BugReportScopeState extends State<BugReportScope> with WidgetsBindingObserver {
  /// [ShakeDetector] instance.
  late final ShakeDetector _shakeDetector;

  /// Flag to determine whether the bug report dialog should be shown on shake.
  bool _useOnShake = true;

  /// Flag to prevent multiple shakes triggering the dialog.
  bool _shaked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _useOnShake = context.ext.dependencies.database.getKey<bool>(BugReportDialog.useOnShakeKey) ?? true;
    _shakeDetector = ShakeDetector(minShakeCount: 7, shakeThresholdGravity: 2);
    _shakeDetector.addListener(_onShakeListener);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shakeDetector
      ..removeListener(_onShakeListener)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _shakeDetector.pause();
    if (state == AppLifecycleState.resumed) _shakeDetector.resume();
  }

  /// Callback for shake detection.
  void _onShakeListener() {
    if (!mounted || !_useOnShake || _shaked) return;
    _shaked = true;
    BugReportDialog.show(context).whenComplete(() => _shaked = false).ignore();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
