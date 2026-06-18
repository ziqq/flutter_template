import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/model/attachment_file.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:flutter_template_name/src/feature/bug_report/bug_report_util.dart';
import 'package:ui/ui.dart';

/// {@template share_error_button}
/// BugReportButton widget.
///
/// Used to send a bug report via the configured report transport.
/// {@endtemplate}
class BugReportButton extends StatefulWidget {
  /// {@macro share_error_button}
  const BugReportButton({
    this.text,
    this.error,
    this.message,
    this.stackTrace,
    this.route,
    this.transport = BugReportTransport.sentry,
    this.attachments = const <AttachmentFile>[],
    this.loading,
    this.onPressed,
    this.onSucceeded,
    this.share = false,
    this.attachLogs = true,
    this.useSnackBar = true,
    super.key, // ignore: unused_element_parameter
  }) : _refresh = false,
       _filled = false;

  /// {@macro share_error_button}
  const BugReportButton.refresh({
    this.text,
    this.error,
    this.message,
    this.stackTrace,
    this.route,
    this.transport = BugReportTransport.sentry,
    this.attachments = const <AttachmentFile>[],
    this.loading,
    this.onPressed,
    this.onSucceeded,
    this.share = false,
    this.attachLogs = true,
    this.useSnackBar = true,
    super.key, // ignore: unused_element_parameter
  }) : _refresh = true,
       _filled = false;

  /// {@macro share_error_button}
  const BugReportButton.filled({
    this.text,
    this.error,
    this.message,
    this.stackTrace,
    this.route,
    this.transport = BugReportTransport.sentry,
    this.attachments = const <AttachmentFile>[],
    this.loading,
    this.onPressed,
    this.onSucceeded,
    this.share = false,
    this.attachLogs = true,
    this.useSnackBar = true,
    super.key, // ignore: unused_element_parameter
  }) : _refresh = false,
       _filled = true;

  /// The text to display on the button.
  final String? text;

  /// The message to share.
  final String? message;

  /// The route where the error occurred.
  final String? route;

  /// The transport used for the bug report.
  final BugReportTransport transport;

  /// Error
  final Object? error;

  /// StackTrace
  final StackTrace? stackTrace;

  /// Optional files attached to the report.
  final List<AttachmentFile> attachments;

  /// Callback to button press.
  final void Function()? onPressed;

  /// Callback to button press.
  final void Function()? onSucceeded;

  /// Whether to show a loading indicator while sharing the error.
  final ValueNotifier<bool>? loading;

  /// Whether to use a SnackBar to show a success message after sharing the error.
  final bool useSnackBar;

  /// Whether to attach logs to the error message.
  final bool attachLogs;

  /// Whether to share the error message in each environment or only in production.
  final bool share;

  /// Whether this button is a refresh button.
  final bool _refresh;

  /// Whether this button is a filled button.
  final bool _filled;

  /// Share error.
  /// This method can be used to share an error message with the bug-report transport.
  /// [share] - whether `true` then the error message will be shared in each environment,
  /// if `false` then the error message will be shared only in production environment.
  static Future<void> shareError(
    BuildContext context, {
    String? text,
    Object? error,
    String? route,
    String? message,
    StackTrace? stackTrace,
    BugReportTransport transport = BugReportTransport.sentry,
    List<AttachmentFile> attachments = const <AttachmentFile>[],
    void Function()? onError,
    void Function()? onSucceeded,
    bool share = false,
    bool attachLogs = true,
    bool useSnackBar = true,
  }) async {
    final dependencies = Dependencies.of(context);
    final user = dependencies.authenticationController.state.user;
    final useHapticFeedback = dependencies.settingsController.state.preferences.useHapticFeedback;
    final reportMessage = message ?? text;

    if (useHapticFeedback) HapticFeedback.heavyImpact().ignore();
    final previewMessage = BugReportUtil.generateErrorMessage(
      user: user,
      route: route,
      error: error,
      message: reportMessage,
      stackTrace: stackTrace,
    );

    if (Config.environment.isDevelopment && kDebugMode && !share) {
      ErrorUtil.displayErrorSnackBar(context, previewMessage);
      onSucceeded?.call();
      return;
    }

    void onSuccess() {
      if (useSnackBar) {
        UI
            .showSnackBar(
              context: context,
              type: UISnackBarType.success,
              useHapticFeedback: useHapticFeedback,
              message: /* ErrorsLocalization.of(context).shareErrorMessageSuccess */ 'Error report sent successfully',
            )
            .ignore();
      }
      onSucceeded?.call();
    }

    BugReportUtil.instance
        .sendReport(
          transport: transport,
          attachLogs: attachLogs,
          attachments: attachments,
          metadata: dependencies.metadata,
          user: user,
          route: route,
          error: error,
          message: reportMessage,
          stackTrace: stackTrace,
          onError: onError,
          onSuccess: onSuccess,
        )
        .ignore();
  }

  @override
  State<BugReportButton> createState() => _BugReportButtonState();
}

/// State for widget [BugReportButton].
class _BugReportButtonState extends State<BugReportButton> {
  /// Storage key for the bug report counter, used to generate unique report IDs.
  static const String _reportCounterKey = '${Config.storageNamespace}.bug_report.counter';

  /// Default duration between error reports.
  late final Duration duration = widget._refresh ? const Duration(minutes: 1) : const Duration(seconds: 30);
  late final ValueNotifier<bool> _loading;

  final ValueNotifier<Duration?> _tick = ValueNotifier<Duration?>(null);
  final ValueNotifier<bool> _disabled = ValueNotifier<bool>(false);

  Duration _tickOffset = .zero;
  Ticker? _ticker;
  Timer? _timer;

  String? _lastRoute, _lastMessage, _lastErrorText, _lastStackTraceText;
  String? _lastAttachmentKey;
  DateTime? _lastSentAt;

  String? get _currentErrorText => widget.error?.toString();
  String? get _currentMessage => widget.message ?? widget.text;
  String? get _currentStackTraceText => widget.stackTrace?.toString();
  String get _currentAttachmentKey => widget.attachments.map((a) => a.path ?? a.name).join('|');

  bool _isSameReport(String? message) =>
      message == _lastMessage &&
      widget.route == _lastRoute &&
      _currentErrorText == _lastErrorText &&
      _currentAttachmentKey == _lastAttachmentKey &&
      _currentStackTraceText == _lastStackTraceText;

  @override
  void initState() {
    super.initState();
    _restoreCooldown();
    _loading = widget.loading ?? ValueNotifier<bool>(false);
  }

  @override
  void didUpdateWidget(covariant BugReportButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _restoreCooldown();
  }

  @override
  void dispose() {
    if (widget.loading == null) _loading.dispose();
    _disabled.dispose();
    _ticker?.dispose();
    _timer?.cancel();
    _tick.dispose();
    super.dispose();
  }

  void _restoreCooldown() {
    final lastSentAt = _lastSentAt;
    if (lastSentAt == null || !_isSameReport(_currentMessage)) {
      _disabled.value = false;
      _tickOffset = .zero;
      _tick.value = null;
      _timer?.cancel();
      _ticker?.stop();
      return;
    }

    final elapsed = DateTime.now().difference(lastSentAt);
    if (elapsed >= duration) {
      _disabled.value = false;
      _tickOffset = .zero;
      _tick.value = null;
      return;
    }

    _disabled.value = true;
    _startTimer(duration - elapsed);
  }

  void _startTimer([Duration? remaining]) {
    final activeDuration = remaining ?? duration;
    _timer?.cancel();
    _ticker?.stop();
    _tickOffset = duration - activeDuration;
    _tick.value = _tickOffset;
    _timer = Timer(activeDuration, () {
      _disabled.value = false;
      _timer?.cancel();
      _ticker?.stop();
      _tickOffset = Duration.zero;
      _tick.value = null;
    });
    if (_ticker != null) {
      _ticker?.start();
    } else {
      _ticker = Ticker((t) => _tick.value = _tickOffset + t)..start();
    }
  }

  /// Generate the next bug report ID.
  BugReportID _nextBugReportID() {
    final next = (context.ext.dependencies.database.getKey<int>(_reportCounterKey) ?? 0) + 1;
    final user = context.ext.dependencies.authenticationController.state.user;
    context.ext.dependencies.database.setKey(_reportCounterKey, next);
    return '${user.id}.$next';
  }

  /// Share error.
  void _onShareError() {
    // Check if enough time has passed since the last successfully sent message.
    final now = DateTime.now();

    final reportMessage = _currentMessage;
    final dependencies = Dependencies.of(context);
    final user = dependencies.authenticationController.state.user;
    final useHapticFeedback = dependencies.settingsController.state.preferences.useHapticFeedback;

    if (useHapticFeedback) HapticFeedback.heavyImpact().ignore();

    // Report error in development mode.
    if (Config.environment.isDevelopment && kDebugMode /* && !widget.share */ ) {
      final message = BugReportUtil.generateErrorMessage(
        user: user,
        route: widget.route,
        error: widget.error,
        message: reportMessage,
        stackTrace: widget.stackTrace,
      );
      ErrorUtil.displayErrorSnackBar(context, message);
      widget.onPressed?.call();
      return;
    }

    final identical = _isSameReport(reportMessage);

    final lastSentAt = _lastSentAt;
    if (lastSentAt != null) {
      final disabled = now.difference(lastSentAt) < duration;
      _disabled.value = disabled && identical;
    }

    if (identical && _disabled.value) {
      _startTimer();
      return;
    }

    if (_disabled.value) {
      _startTimer();
      return;
    }

    _loading.value = true;
    widget.onPressed?.call();

    void onSuccess() {
      _lastSentAt = DateTime.now();
      _lastStackTraceText = _currentStackTraceText;
      _lastErrorText = _currentErrorText;
      _lastMessage = reportMessage;
      _lastRoute = widget.route;
      _lastAttachmentKey = _currentAttachmentKey;
      _disabled.value = true;
      _loading.value = false;
      _startTimer();

      widget.onSucceeded?.call();
      if (widget.useSnackBar) {
        UI
            .showSnackBar(
              context: context,
              type: UISnackBarType.success,
              useHapticFeedback: useHapticFeedback,
              message: /* ErrorsLocalization.of(context).shareErrorMessageSuccess */ 'Error report sent successfully',
            )
            .ignore();
      }
    }

    BugReportUtil.instance
        .sendReport(
          attachments: widget.attachments,
          attachLogs: widget.attachLogs,
          metadata: dependencies.metadata,
          reportID: _nextBugReportID(),
          transport: widget.transport,
          message: reportMessage,
          user: user,
          route: widget.route,
          error: widget.error,
          stackTrace: widget.stackTrace,
          onSuccess: onSuccess,
          onError: () => _loading.value = false,
        )
        .ignore();
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = ErrorsLocalization.of(context);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([_disabled, _loading, _tick]),
      builder: (_, _) {
        final disabled = _disabled.value || _loading.value;
        final tick = _tick.value;
        if (widget._refresh) {
          return SizedBox(
            height: theme.uiTheme.size.button.small,
            child: CupertinoButton(
              padding: EdgeInsets.symmetric(horizontal: theme.uiTheme.padding),
              color: disabled
                  ? theme.uiTheme.color.onBackground /* .darken(.05) */
                  : theme.uiTheme.color.accent.withValues(alpha: .1),
              onPressed: disabled ? null : _onShareError,
              child: Text(
                '${widget.text ?? "l10n.refreshButton"}${tick != null && (duration - tick).inSeconds > 0 ? ' (${(duration - tick).inSeconds} ${"AppLocalization.of(context).secondShortLabel"})' : ''}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: disabled
                      ? CupertinoDynamicColor.resolve(CupertinoColors.inactiveGray, context)
                      : theme.uiTheme.color.accent,
                  fontWeight: .w600,
                ),
              ),
            ),
          );
        }
        return CupertinoButton(
          color: widget._filled
              ? disabled
                    ? theme.uiTheme.color.onBackground /* .darken(.05) */
                    : theme.uiTheme.color.accent
              : null,
          onPressed: disabled ? null : _onShareError,
          child: Text(
            '${widget.text ?? "l10n.shareErrorButton"}${tick != null && (duration - tick).inSeconds > 0 ? ' (${(duration - tick).inSeconds} ${"AppLocalization.of(context).secondShortLabel"})' : ''}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: widget._filled ? .w500 : null,
              color: disabled
                  ? CupertinoDynamicColor.resolve(CupertinoColors.inactiveGray, context)
                  : widget._filled
                  ? theme.uiTheme.color.onAccent
                  : theme.uiTheme.color.accent,
            ),
          ),
        );
      },
    );
  }
}
