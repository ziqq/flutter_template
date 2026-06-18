/*
 * Date: 24 December 2024
 */

import 'package:flutter/cupertino.dart' show CupertinoColors, CupertinoDynamicColor;
import 'package:flutter_template_name/src/common/api_client/api_exception.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:flutter_template_name/src/common/widget/common_back_button.dart';
import 'package:flutter_template_name/src/common/widget/common_bottom_spacer.dart';
import 'package:flutter_template_name/src/common/widget/common_padding.dart';
import 'package:flutter_template_name/src/feature/bug_report/widget/bug_report_button.dart';
import 'package:ui/ui.dart';

/// {@template error_screen}
/// ErrorScreen widget.
///
/// This widget is used to display an error screen.
/// {@endtemplate}
class ErrorScreen extends StatelessWidget {
  /// {@macro error_screen}
  const ErrorScreen({
    this.stackTrace,
    this.error,
    this.route,
    this.tryAgain,
    this.automaticallyImplyLeading = true,
    super.key,
  });

  /// Controls whether we should try to imply the leading widget if null.
  /// Default value is `true`.
  final bool automaticallyImplyLeading;

  /// The route where the error occurred.
  final String? route;

  /// Error
  final Object? error;

  /// StackTrace
  final StackTrace? stackTrace;

  /// Try again callback
  final void Function()? tryAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UIAnnotateRegion(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          automaticallyImplyLeading: automaticallyImplyLeading,
          leading: automaticallyImplyLeading ? const CommonBackButton() : null,
        ),
        body: Center(
          child: Padding(
            padding: CommonPadding.of(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (error != null) const Spacer(),
                CommonErrorWidget$Title(error),
                SizedBox(height: theme.uiTheme.indent),
                CommonErrorWidget$Subtitle(error),
                if (tryAgain != null) ...[
                  SizedBox(height: theme.uiTheme.padding * 2),
                  BugReportButton.refresh(
                    route: route,
                    error: error,
                    stackTrace: stackTrace,
                    onPressed: tryAgain ?? () => Navigator.of(context).pop<void>(),
                  ),
                ],
                if (error != null) ...[
                  const Spacer(),
                  BugReportButton(route: route, error: error, stackTrace: stackTrace),
                ],
                const CommonBottomSpacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// {@template common_error_widget}
/// CommonErrorWidget widget.
/// Used to display a common error message with an optional "Try Again" button.
///
/// [CommonErrorWidget.simple] variant is a simplified version without LayoutBuilder, usually for use intro slivers.
/// {@endtemplate}
class CommonErrorWidget extends StatefulWidget {
  /// {@macro common_error_widget}
  const CommonErrorWidget({
    this.tryAgain,
    this.error,
    this.stackTrace,
    this.route,
    this.title,
    this.subtitle,
    super.key,
  }) : _simple = false,
       _buttonless = false;

  /// Constructor for buttonless variant.
  /// {@macro common_error_widget}
  const CommonErrorWidget.buttonless({
    this.tryAgain,
    this.error,
    this.stackTrace,
    this.route,
    this.title,
    this.subtitle,
    super.key,
  }) : _simple = true,
       _buttonless = true;

  /// Constructor for simple variant without [LayoutBuilder].
  /// {@macro common_error_widget}
  const CommonErrorWidget.simple({
    this.tryAgain,
    this.error,
    this.stackTrace,
    this.route,
    this.title,
    this.subtitle,
    super.key,
  }) : _simple = true,
       _buttonless = false;

  /// Title of the widget
  final String? title;

  /// Subtitle of the widget
  final String? subtitle;

  /// CommonErrorWidget
  final Object? error;

  /// The route where the error occurred.
  final String? route;

  /// StackTrace
  final StackTrace? stackTrace;

  /// Try again callback
  final void Function()? tryAgain;

  /// Whether to show the button or not.
  final bool _buttonless;

  /// Whether to use simple layout without LayoutBuilder.
  final bool _simple;

  @override
  State<CommonErrorWidget> createState() => _CommonErrorWidgetState();
}

/// State for widget [CommonErrorWidget].
class _CommonErrorWidgetState extends State<CommonErrorWidget> {
  @override
  void initState() {
    super.initState();
    if (widget._buttonless) {
      final error = widget.error;
      if (error != null) {
        ErrorUtil.logError(
          error,
          widget.stackTrace ?? StackTrace.current,
          hints: <String, Object?>{'route': widget.route},
        ).ignore();
      }
      BugReportButton.shareError(
        context,
        error: error,
        useSnackBar: false,
        route: widget.route,
        stackTrace: widget.stackTrace,
      ).ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget addLayoutBuilder({required Widget child}) => widget._simple
        ? child
        : LayoutBuilder(
            builder: (context, constraints) => SizedBox(width: constraints.maxWidth, child: child),
          );

    final theme = Theme.of(context);
    final showRefreshButton = switch (widget.error) {
      ApiException$Authorization() => false,
      _ => true,
    };

    return addLayoutBuilder(
      child: Padding(
        padding: CommonPadding.of(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonErrorWidget$Icon(widget.error),
            SizedBox(height: theme.uiTheme.padding / 1.5),
            CommonErrorWidget$Title(widget.error, text: widget.title),
            SizedBox(height: theme.uiTheme.padding / 3),
            CommonErrorWidget$Subtitle(widget.error, text: widget.subtitle),
            if (showRefreshButton && !widget._buttonless) ...[
              SizedBox(height: theme.uiTheme.padding * 1.5),
              BugReportButton.refresh(
                route: widget.route,
                error: widget.error,
                stackTrace:
                    widget.stackTrace ??
                    switch (widget.error) {
                      ApiException e => e.stackTrace,
                      _ => null,
                    },
                share: true,
                useSnackBar: false,
                onPressed: widget.tryAgain,
              ),
            ],
            const CommonBottomSpacer(),
          ],
        ),
      ),
    );
  }
}

/// CommonErrorWidget icon widget.
/// {@macro common_error_widget}
class CommonErrorWidget$Icon extends StatelessWidget {
  /// {@macro common_error_widget}
  const CommonErrorWidget$Icon(this.error, {super.key});

  /// An error object that occurred
  /// and determines which icon to display.
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = theme.uiTheme.size.icon.large * 2;
    return switch (error) {
      ApiException$Offline _ => Icon(Icons.network_check_rounded, color: theme.colorScheme.error, size: size),
      ApiException$Network(statusCode: != 500) => Icon(
        Icons.network_check_rounded,
        color: CupertinoDynamicColor.resolve(CupertinoColors.systemBlue, context),
        size: size,
      ),
      _ => /* UIIcon$Stub$EngineeringWork(size: size) */ Icon(
        Icons.engineering_rounded,
        color: theme.colorScheme.onSurfaceVariant,
        size: size,
      ),
    };
  }
}

/// CommonErrorWidget title widget.
/// {@macro common_error_widget}
class CommonErrorWidget$Title extends StatelessWidget {
  /// {@macro common_error_widget}
  const CommonErrorWidget$Title(
    this.error, {
    this.text,
    super.key, // ignore: unused_element
  }) : _secondary = false;

  const CommonErrorWidget$Title.secondary(
    this.error, {
    this.text,
    super.key, // ignore: unused_element
  }) : _secondary = true;

  /// An error object that occurred
  /// and determines which title to display.
  final Object? error;

  /// Optional text to display in the title.
  final String? text;

  /// Whether this title is secondary.
  final bool _secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text ??
          switch (error) {
            ApiException(
              code: 'internal_server_error' || 'server_error',
            ) => /* context.ext.l10n.errors.serverErrorTitle */
              'Server error',
            ApiException(code: 'network_error') => /* context.ext.l10n.errors.noConnectionTitle */ 'No connection',
            _ => /* context.ext.l10n.errors.somethingWentWrongTitle */ 'Something went wrong',
          },
      textAlign: TextAlign.center,
      style: _secondary ? theme.textTheme.headlineMedium : theme.textTheme.displaySmall,
    );
  }
}

/// CommonErrorWidget subtitle widget.
/// {@macro common_error_widget}
class CommonErrorWidget$Subtitle extends StatelessWidget {
  /// {@macro common_error_widget}
  const CommonErrorWidget$Subtitle(
    this.error, {
    this.text,
    super.key, // ignore: unused_element
  });

  /// An error object that occurred
  /// and determines which subtitle to display.
  final Object? error;

  /// Optional text to display in the subtitle.
  final String? text;

  @override
  Widget build(BuildContext context) {
    // final l10n = ErrorsLocalization.of(context);
    final theme = Theme.of(context);
    return Text(
      text ??
          switch (error) {
            ApiException(code: 'internal_server_error' || 'server_error') => /* l10n.serverErrorSubtitle */
              'Please try again later.',
            ApiException(code: 'network_error') => /* l10n.noConnectionSubtitle */
              'Please check your internet connection and try again.',
            _ => /* l10n.somethingWentWrongSubtitle */ 'An unexpected error occurred. Please try again.',
          },
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(color: theme.uiTheme.color.textSecondary),
    );
  }
}

/// {@template try_again_widget}
/// TryAgainWidget widget.
/// Used to display an error message with an optional "Try Again" button.
/// {@endtemplate}
class TryAgainWidget extends StatefulWidget {
  /// {@macro try_again_widget}
  const TryAgainWidget({this.tryAgain, this.title, this.subtitle, this.error, this.stackTrace, this.route, super.key})
    : _buttonless = false;

  /// Constructor for buttonless variant.
  /// {@macro try_again_widget}
  const TryAgainWidget.buttonless({
    this.tryAgain,
    this.title,
    this.subtitle,
    this.error,
    this.stackTrace,
    this.route,
    super.key,
  }) : _buttonless = true;

  /// Title of the widget
  final String? title;

  /// Subtitle of the widget
  final String? subtitle;

  /// The route where the error occurred.
  final String? route;

  /// CommonErrorWidget that occurred
  final Object? error;

  /// Stack trace of the error
  final StackTrace? stackTrace;

  /// Try again callback
  final void Function()? tryAgain;

  /// Whether to show the button or not.
  final bool _buttonless;

  @override
  State<TryAgainWidget> createState() => _TryAgainWidgetState();
}

/// State for widget [TryAgainWidget].
class _TryAgainWidgetState extends State<TryAgainWidget> {
  @override
  void initState() {
    super.initState();
    if (widget._buttonless) {
      final error = widget.error;
      if (error != null) {
        ErrorUtil.logError(
          error,
          widget.stackTrace ?? StackTrace.current,
          hints: <String, Object?>{'route': widget.route},
        ).ignore();
      }
      BugReportButton.shareError(
        context,
        error: error,
        useSnackBar: false,
        route: widget.route,
        stackTrace: widget.stackTrace,
      ).ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showRefreshButton = switch (widget.error) {
      ApiException$Authorization() => false,
      _ => true,
    };
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonErrorWidget$Title.secondary(widget.error, text: widget.title),
            const SizedBox(height: 2),
            CommonErrorWidget$Subtitle(widget.error, text: widget.subtitle),
            if (showRefreshButton && !widget._buttonless) ...[
              SizedBox(height: theme.uiTheme.padding),
              BugReportButton.refresh(
                route: widget.route,
                error: widget.error,
                stackTrace: widget.stackTrace,
                useSnackBar: false,
                onPressed: widget.tryAgain,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
