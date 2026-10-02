import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/util/date_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template_name/src/common/widget/common_bottom_spacer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:l/l.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/util/log_buffer.dart';
import 'package:flutter_template_name/src/common/widget/common_back_button.dart';
import 'package:flutter_template_name/src/common/widget/fake_liquid_glass_wrapper.dart';
import 'package:flutter_template_name/src/feature/bug_report/bug_report_util.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:ui/ui.dart';

/// {@template logs_screen}
/// LogsScreen widget.
/// {@endtemplate}
class LogsScreen extends StatelessWidget {
  /// {@macro logs_screen}
  const LogsScreen({super.key});

  /// Show the logs screen

  @override
  Widget build(BuildContext context) => const Scaffold(body: _Logs$List());
}

/// {@template logs_dialog}
/// Logs$Dialog widget.
/// {@endtemplate}
class Logs$Dialog extends StatelessWidget {
  /// {@macro logs_dialog}
  const Logs$Dialog({super.key});

  /// Show the logs screen
  static Future<void> show(BuildContext context) =>
      showDialog<void>(context: context, builder: (context) => const Logs$Dialog());

  @override
  Widget build(BuildContext context) => Dialog(
    elevation: 0,
    insetPadding: .all(Theme.of(context).uiTheme.padding),
    shape: RoundedRectangleBorder(borderRadius: UIBorderRadius.regular(context)),
    child: ClipRRect(borderRadius: UIBorderRadius.regular(context), child: const _Logs$List()),
  );
}

/// {@template logs_screen}
/// _Logs$List widget.
/// {@endtemplate}
class _Logs$List extends StatefulWidget {
  /// {@macro logs_screen}
  const _Logs$List();

  @override
  State<_Logs$List> createState() => _Logs$ListState();
}

/// State for widget [_Logs$List].
class _Logs$ListState extends State<_Logs$List> {
  final TextEditingController _controller = TextEditingController();
  final LogBuffer buffer = LogBuffer.instance;
  List<LogMessage> logs = <LogMessage>[], filteredLogs = <LogMessage>[];
  int _filterGeneration = 0;

  @override
  void initState() {
    super.initState();
    buffer.addListener(_onLogUpdated);
    _controller.addListener(_filter);
    _onLogUpdated();
  }

  @override
  void dispose() {
    buffer.removeListener(_onLogUpdated);
    _controller
      ..removeListener(_filter)
      ..dispose();
    super.dispose();
  }

  void _onLogUpdated() {
    logs = buffer.logs.toList();
    _filter();
  }

  Future<void> _filter() async {
    final generation = ++_filterGeneration;
    final search = _controller.text.toLowerCase();
    final stopwatch = Stopwatch()..start();
    final buffer = logs.toList();
    try {
      LogMessage log;
      var pos = 0;
      for (var i = 0; i < buffer.length; i++) {
        if (stopwatch.elapsedMilliseconds > 8) {
          await Future<void>.delayed(Duration.zero);
          if (!mounted || generation != _filterGeneration) return;
          stopwatch.reset();
        }
        log = buffer[i];
        if (log.message.toString().toLowerCase().contains(search)) {
          buffer[pos] = log;
          pos++;
        }
      }
      if (!mounted || generation != _filterGeneration) return;
      filteredLogs = buffer..length = pos;
    } finally {
      stopwatch.stop();
    }
    if (mounted) setState(() {});
  }

  /// Clear logs
  void _onClear() {
    final dependencies = Dependencies.of(context);
    final database = dependencies.database;
    if (dependencies.settingsController.state.preferences.useHapticFeedback) {
      HapticFeedback.heavyImpact().ignore();
    }
    database.delete(database.logTbl).go().ignore();
    buffer.clear();
    logs.clear();
    filteredLogs.clear();
  }

  /// Share logs
  void _onShare() {
    final dependencies = Dependencies.of(context);
    if (dependencies.settingsController.state.preferences.useHapticFeedback) {
      HapticFeedback.heavyImpact().ignore();
    }
    BugReportUtil.instance
        .shareReport(
          message: 'Application logs export.',
          route: 'LogsScreen',
          user: dependencies.authenticationController.state.user,
          metadata: dependencies.metadata,
          attachLogs: true,
        )
        .ignore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final theme = Theme.of(context);
    final counterWidget = DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemFill, context),
        borderRadius: const .all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 7, vertical: 3),
        child: Text(
          '${filteredLogs.length}',
          style: theme.textTheme.labelSmall?.copyWith(fontSize: 12, fontWeight: .w500, color: theme.uiTheme.color.text),
        ),
      ),
    );
    return CupertinoPageScaffold(
      backgroundColor: theme.uiTheme.color.background,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar.search(
            searchField: CupertinoSearchTextField(controller: _controller),
            backgroundColor: theme.uiTheme.color.background,
            padding: .zero,
            leading: const CommonBackButton(),
            largeTitle: Text(l10n.developerLogsLabel),
            alwaysShowMiddle: false,
            middle: Row(
              mainAxisAlignment: .center,
              spacing: theme.uiTheme.size.offset.extraExtraSmall,
              children: <Widget>[
                Text(l10n.developerLogsLabel, style: theme.textTheme.headlineMedium),
                counterWidget,
              ],
            ),
            trailing: _Logs$Actions(onShare: _onShare, onClear: _onClear),
          ),
          if (filteredLogs.isEmpty)
            SliverFillRemaining(
              child: Padding(
                padding: .only(bottom: CommonBottomSpacer.heightOf(context)),
                child: Center(
                  child: Text(
                    l10n.developerLogsEmptyLabel,
                    style: theme.textTheme.headlineMedium?.copyWith(color: theme.uiTheme.color.textSecondary),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _LogTile(filteredLogs[index], key: ObjectKey(filteredLogs[index])),
                childCount: filteredLogs.length,
              ),
            ),
        ],
      ),
    );
  }
}

/// App bar actions for sharing and clearing logs.
class _Logs$Actions extends StatelessWidget {
  const _Logs$Actions({required this.onShare, required this.onClear});

  final VoidCallback onShare;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final prefs = SettingsScope.userPreferencesOf(context);
    final theme = Theme.of(context);
    return Padding(
      padding: .only(
        right: prefs.useIOS26LiquidTheme
            ? theme.uiTheme.size.offset.regular
            : theme.uiTheme.size.offset.extraExtraSmall,
      ),
      child: FakeLiquidGlassWrapper(
        scale: 1,
        child: Row(
          mainAxisSize: .min,
          children: <Widget>[
            Tooltip(
              message: l10n.developerSendLogsButton,
              child: CupertinoButton(
                onPressed: onShare,
                padding: .zero,
                child: Icon(
                  CupertinoIcons.share,
                  color: theme.uiTheme.color.text,
                  size: theme.uiTheme.size.icon.regular,
                ),
              ),
            ),
            Tooltip(
              message: l10n.developerClearLogsButton,
              child: CupertinoButton(
                onPressed: onClear,
                padding: .zero,
                child: Icon(
                  CupertinoIcons.delete,
                  color: CupertinoDynamicColor.resolve(CupertinoColors.destructiveRed, context),
                  size: theme.uiTheme.size.icon.regular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template logs_screen}
/// _LogTile widget.
/// {@endtemplate}
class _LogTile extends StatelessWidget {
  /// {@macro logs_screen}
  const _LogTile(this.log, {super.key});

  final LogMessage log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        CupertinoListTile(
          onTap: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(Localization.of(context).errorDetailsDialogLabel),
              content: SingleChildScrollView(
                child: SelectableText(
                  [
                    '${log.timestamp.format()} | ${log.level}',
                    log.message.toString(),
                    if (log case LogMessageError(:final stackTrace)) stackTrace.toString(),
                  ].join('\n\n'),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(Localization.of(context).cancelButton)),
              ],
            ),
          ),
          title: Row(
            spacing: theme.uiTheme.size.offset.extraExtraSmall,
            children: <Widget>[
              _LogIcon(log.level),
              Expanded(
                child: Text(
                  log.timestamp.format(),
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 12, fontWeight: .normal),
                ),
              ),
              _LogType(log.level),
            ],
          ),
          subtitle: Text(
            log.message.toString(),
            style: theme.textTheme.labelSmall?.copyWith(color: theme.uiTheme.color.text, fontWeight: .w400),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

/// _LogIcon widget.
/// {@macro logs_screen}
class _LogIcon extends StatelessWidget {
  /// {@macro logs_screen}
  const _LogIcon(this.level);

  final LogLevel level;

  @override
  Widget build(BuildContext context) {
    Color resolve(Color color) => CupertinoDynamicColor.resolve(color, context);
    final size = Theme.of(context).uiTheme.size.icon.extraSmall;
    final prefix = level.when(
      // Verbose and so on
      v: () => '1️⃣',
      vv: () => '2️⃣',
      vvv: () => '3️⃣',
      vvvv: () => '4️⃣',
      vvvvv: () => '5️⃣',
      vvvvvv: () => '6️⃣',

      // Standart logs levels
      debug: () => '🔍', // debug message
      info: () => 'ℹ️', // information message
      warning: () => '⚠️', // warnings
      error: () => '❌', // errors
      shout: () => '📣', // critical
    );
    final color = level.when(
      debug: () => resolve(CupertinoColors.systemBlue),
      info: () => resolve(CupertinoColors.systemGreen),
      warning: () => resolve(CupertinoColors.systemOrange),
      error: () => resolve(CupertinoColors.systemRed),
      shout: () => resolve(CupertinoColors.systemRed),
      v: () => resolve(CupertinoColors.systemGrey),
      vv: () => resolve(CupertinoColors.systemGrey),
      vvv: () => resolve(CupertinoColors.systemGrey),
      vvvv: () => resolve(CupertinoColors.systemGrey),
      vvvvv: () => resolve(CupertinoColors.systemGrey),
      vvvvvv: () => resolve(CupertinoColors.systemGrey),
    );
    return Text(
      prefix,
      style: TextStyle(fontSize: size, color: color),
    );
    /* return level.when<Widget>(
      debug: () => Icon(Icons.bug_report, color: resolve(CupertinoColors.systemBlue), size: size),
      info: () => Icon(Icons.info, color: resolve(CupertinoColors.systemGreen), size: size),
      warning: () => Icon(Icons.warning, color: resolve(CupertinoColors.systemOrange), size: size),
      error: () => Icon(Icons.error, color: resolve(CupertinoColors.systemRed), size: size),
      shout: () => Icon(Icons.campaign, color: resolve(CupertinoColors.systemRed), size: size),
      v: () => Icon(Icons.looks_one, color: resolve(CupertinoColors.systemGrey), size: size),
      vv: () => Icon(Icons.looks_two, color: resolve(CupertinoColors.systemGrey), size: size),
      vvv: () => Icon(Icons.looks_3, color: resolve(CupertinoColors.systemGrey), size: size),
      vvvv: () => Icon(Icons.looks_4, color: resolve(CupertinoColors.systemGrey), size: size),
      vvvvv: () => Icon(Icons.looks_5, color: resolve(CupertinoColors.systemGrey), size: size),
      vvvvvv: () => Icon(Icons.looks_6, color: resolve(CupertinoColors.systemGrey), size: size),
    ); */
  }
}

/// LogsScreen widget.
/// {@macro logs_screen}
class _LogType extends StatelessWidget {
  /// {@macro logs_screen}
  const _LogType(
    this.level, {
    super.key, // ignore: unused_element_parameter
  });

  final LogLevel level;

  @override
  Widget build(BuildContext context) {
    Color resolve(Color color) => CupertinoDynamicColor.resolve(color, context);
    final color = level.when(
      debug: () => resolve(CupertinoColors.systemBlue),
      info: () => resolve(CupertinoColors.systemGreen),
      warning: () => resolve(CupertinoColors.systemOrange),
      error: () => resolve(CupertinoColors.systemRed),
      shout: () => resolve(CupertinoColors.systemRed),
      v: () => resolve(CupertinoColors.systemGrey),
      vv: () => resolve(CupertinoColors.systemGrey),
      vvv: () => resolve(CupertinoColors.systemGrey),
      vvvv: () => resolve(CupertinoColors.systemGrey),
      vvvvv: () => resolve(CupertinoColors.systemGrey),
      vvvvvv: () => resolve(CupertinoColors.systemGrey),
    );
    final text = level.maybeWhen(
      orElse: () => 'debug',
      error: () => 'error',
      warning: () => 'warning',
      debug: () => 'debug',
      info: () => 'info',
      shout: () => 'shout',
      v: () => 'v',
      vv: () => 'vv',
      vvv: () => 'vvv',
      vvvv: () => 'vvvv',
      vvvvv: () => 'vvvvv',
      vvvvvv: () => 'vvvvvv',
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: .all(.circular(Theme.of(context).uiTheme.size.corner.extraExtraSmall)),
      ),
      child: Padding(
        padding: .symmetric(horizontal: Theme.of(context).uiTheme.size.offset.extraExtraSmall, vertical: 2),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12, fontWeight: .w600, color: color),
        ),
      ),
    );
  }
}
