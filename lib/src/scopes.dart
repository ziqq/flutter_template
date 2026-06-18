import 'package:flutter/widgets.dart';
import 'package:flutter_template_name/src/common/router/app_navigator.dart';
import 'package:flutter_template_name/src/common/util/connectivity/connectivity_scope.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/authentication_scope.dart';
import 'package:flutter_template_name/src/feature/bug_report/widget/bug_report_scope.dart';

/// {@template scopes}
/// Scopes widget.
///
/// This widget is responsible for providing the necessary scopes to the widget tree.
/// {@endtemplate}
class Scopes extends StatelessWidget {
  /// {@macro scopes}
  const Scopes({required this.navigator, super.key});

  /// App navigator instance to be provided to the widget tree.
  final AppNavigator navigator;

  @override
  Widget build(BuildContext context) => ConnectivityWidget(
    child: AuthenticationScope(child: BugReportScope(child: navigator)),
  );
}
