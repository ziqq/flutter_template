import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback, Clipboard, ClipboardData;
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/common/util/date_util.dart';
import 'package:flutter_template_name/src/common/util/log_buffer.dart';
import 'package:flutter_template_name/src/common/widget/common_back_button.dart';
import 'package:flutter_template_name/src/common/widget/common_bottom_spacer.dart';
import 'package:l/l.dart';
import 'package:ui/ui.dart';

/// {@template logs_screen}
/// LogsScreen widget.
/// {@endtemplate}
class LogsScreen extends StatelessWidget {
  /// {@macro logs_screen}
  const LogsScreen({super.key});

  /// Show the logs screen
  static Future<void> show(BuildContext context) => Navigator.of(
    context,
    rootNavigator: true,
  ).push<void>(MaterialPageRoute<void>(builder: (context) => const LogsScreen()));

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
    insetPadding: EdgeInsets.all(Theme.of(context).uiTheme.padding),
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
  late List<LogMessage> logs, filteredLogs;

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
    final search = _controller.text.toLowerCase();
    final stopwatch = Stopwatch()..start();
    final buffer = logs.toList();
    try {
      LogMessage log;
      var pos = 0;
      for (var i = 0; i < buffer.length; i++) {
        if (stopwatch.elapsedMilliseconds > 8) {
          await Future<void>.delayed(Duration.zero);
        }
        log = logs[i];
        if (log.message.toString().toLowerCase().contains(search)) {
          buffer[pos] = log;
          pos++;
        }
      }
      filteredLogs = buffer..length = pos;
    } finally {
      stopwatch.stop();
    }
    if (mounted) setState(() {});
  }

  /// Clear logs
  void _onClear() {
    final useHapticFeedback = context.ext.dependencies.settingsController.state.preferences.useHapticFeedback;
    if (useHapticFeedback) HapticFeedback.heavyImpact().ignore();

    context.ext.dependencies.database.delete(context.ext.dependencies.database.logTbl).go().ignore();
    buffer.clear();
    logs.clear();
    filteredLogs.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = Localization.of(context);
    final counterWidget = DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemFill, context),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          '${filteredLogs.length}',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.uiTheme.color.text,
          ),
        ),
      ),
    );
    return CupertinoPageScaffold(
      backgroundColor: theme.uiTheme.color.background,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar.search(
            leading: CommonBackButton(onPressed: () => Navigator.of(context, rootNavigator: true).maybePop<void>()),
            padding: EdgeInsetsDirectional.only(end: theme.uiTheme.padding),
            backgroundColor: theme.uiTheme.color.background,
            searchField: CupertinoSearchTextField(
              controller: _controller,
              style: theme.uiTheme.placeholderStyle,
              placeholderStyle: theme.uiTheme.placeholderStyle,
              cursorHeight: theme.uiTheme.placeholderStyle?.fontSize,
              padding: EdgeInsetsDirectional.fromSTEB(
                theme.uiTheme.indent / 2,
                theme.uiTheme.indent / 4,
                theme.uiTheme.indent / 2,
                theme.uiTheme.indent / 2,
              ),
            ),
            alwaysShowMiddle: false,
            middle: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: theme.uiTheme.indent / 2,
              children: <Widget>[
                Text(l10n.logs, style: theme.textTheme.headlineMedium),
                counterWidget,
              ],
            ),
            largeTitle: Text(l10n.logs, style: theme.textTheme.displayLarge),
            trailing: GestureDetector(
              onTap: _onClear,
              child: Text(
                l10n.clearButton,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: CupertinoDynamicColor.resolve(CupertinoColors.systemRed, context),
                ),
              ),
            ),
          ),
          if (filteredLogs.isEmpty)
            SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.only(bottom: CommonBottomSpacer.heightOf(context)),
                child: Center(
                  child: Text(
                    l10n.noLogsYet,
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
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: theme.uiTheme.padding, right: theme.uiTheme.padding / 4),
          leading: _LogIcon(log.level),
          title: Text(
            log.message.toString(),
            style: theme.textTheme.labelSmall?.copyWith(color: theme.uiTheme.color.text, fontWeight: FontWeight.w400),
          ),
          subtitle: Text(log.timestamp.format(), style: theme.textTheme.labelSmall),
          trailing: IconButton(
            icon: Icon(Icons.copy, color: theme.uiTheme.color.textSecondary),
            onPressed: () => Clipboard.setData(
              ClipboardData(
                text: switch (log) {
                  LogMessageError log => '${log.message}\n${log.stackTrace}',
                  _ => '${log.message}',
                },
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

/// {@template logs_screen}
/// _LogIcon widget.
/// {@endtemplate}
class _LogIcon extends StatelessWidget {
  /// {@macro logs_screen}
  const _LogIcon(this.level);

  final LogLevel level;

  @override
  Widget build(BuildContext context) {
    Color resolve(Color color) => CupertinoDynamicColor.resolve(color, context);
    return level.when<Widget>(
      debug: () => Icon(Icons.bug_report, color: resolve(CupertinoColors.systemIndigo)),
      info: () => Icon(Icons.info, color: resolve(CupertinoColors.systemBlue)),
      warning: () => Icon(Icons.warning, color: resolve(CupertinoColors.systemOrange)),
      error: () => Icon(Icons.error, color: resolve(CupertinoColors.systemRed)),
      shout: () => Icon(Icons.campaign, color: resolve(CupertinoColors.systemRed)),
      v: () => Icon(Icons.looks_one, color: resolve(CupertinoColors.systemGrey)),
      vv: () => Icon(Icons.looks_two, color: resolve(CupertinoColors.systemGrey)),
      vvv: () => Icon(Icons.looks_3, color: resolve(CupertinoColors.systemGrey)),
      vvvv: () => Icon(Icons.looks_4, color: resolve(CupertinoColors.systemGrey)),
      vvvvv: () => Icon(Icons.looks_5, color: resolve(CupertinoColors.systemGrey)),
      vvvvvv: () => Icon(Icons.looks_6, color: resolve(CupertinoColors.systemGrey)),
    );
  }
}
