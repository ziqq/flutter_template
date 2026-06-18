import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/common/widget/common_bottom_spacer.dart';
import 'package:flutter_template_name/src/common/widget/common_padding.dart';
import 'package:flutter_template_name/src/feature/bug_report/widget/bug_report_button.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:ui/ui.dart';

/// {@template bug_report_dialog}
/// BugReportDialog widget.
/// This widget is used to report bugs or issues in the application.
/// {@endtemplate}
class BugReportDialog extends StatefulWidget {
  const BugReportDialog({
    super.key, // ignore: unused_element_parameter
  });

  /// Key for storing the user's preference on whether to use the bug report dialog on shake.
  /// This key is used to save the user's preference in the database and retrieve it when needed.
  /// The value is a `boolean` that indicates whether the bug report dialog should be shown when the device is shaken.
  /// Default value is `true`, meaning that the dialog will be shown on shake unless the user explicitly disables it.
  static String useOnShakeKey = 'use_bug_report_dialog_on_shake';

  /// Show bug report dialog.
  static Future<void> show(BuildContext context) async {
    final prefs = SettingsScope.userPreferencesOf(context, listen: false);
    if (prefs.useHapticFeedback == true) HapticFeedback.vibrate().ignore();
    await UI.showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      useRootNavigator: true,
      isScrollControlled: true,
      useHapticFeedback: false,
      builder: (context) => ClipRRect(borderRadius: UIBorderRadius.regular(context), child: const BugReportDialog()),
    );
  }

  @override
  State<BugReportDialog> createState() => _BugReportDialogState();
}

/// State for widget [BugReportDialog].
class _BugReportDialogState extends State<BugReportDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ValueNotifier<bool> _useOnShake = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _attachLogs = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _useOnShake.value = context.ext.dependencies.database.getKey<bool>(BugReportDialog.useOnShakeKey) ?? true;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _attachLogs.dispose();
    _useOnShake.dispose();
    _loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UIAnnotateRegion.secondary(
      child: UIDismissKeyboard(
        child: ColoredBox(
          color: theme.uiTheme.color.secondaryBackground,
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: <Widget>[
              /* const UIAppBar$Devider(), */
              Flexible(
                child: SingleChildScrollView(
                  padding: CommonPadding.of(context),
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: <Widget>[
                      SizedBox(height: theme.uiTheme.size.offset.regular),
                      // --- Title --- //
                      Text(Localization.of(context).bugReportDialogTitle, style: theme.textTheme.headlineLarge),
                      SizedBox(height: theme.uiTheme.size.offset.small),
                      // --- Subtitle --- //
                      Text(
                        Localization.of(context).bugReportDialogDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.2),
                      ),
                      SizedBox(height: theme.uiTheme.size.offset.large),
                      // --- Form with attached logs --- //
                      UIListSection.secodary(
                        textFooter: Localization.of(context).bugReportAttachLogsHelpText,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              /* UICupertinoTextInput(
                                minLines: 1,
                                maxLines: 8,
                                maxLength: 1000,
                                controller: _messageController,
                                decoration: BoxDecoration(
                                  borderRadius: UIBorderRadius.regular(context),
                                  color: theme.uiTheme.color.onSecondaryBackground,
                                ),
                                textInputAction: .newline,
                                textCapitalization: .sentences,
                                cursorHeight: theme.textTheme.bodyMedium?.fontSize,
                                style: theme.textTheme.bodyLarge?.copyWith(height: 1.1),
                                placeholder: context.ext.l10n.errors.shareErrorDialogDescribeTheProblemLabel,
                                placeholderStyle: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.uiTheme.color.textSecondary,
                                  height: 1.1,
                                ),
                              ), */
                              ValueListenableBuilder(
                                valueListenable: _messageController,
                                builder: (context, message, _) => message.text.length < 100
                                    ? const SizedBox.shrink()
                                    : Positioned(
                                        bottom: 5,
                                        right: 8,
                                        child: Text(
                                          message.text.isEmpty
                                              ? ''
                                              : /* '${message.text.length} ${context.ext.l10n.app.ofSeparator.toLowerCase()} 1000' */ '${message.text.length} / 1000',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: _attachLogs,
                            builder:
                                (_, value, _) => /* UICupertinoFormRow.withSwitch(
                              value: value,
                              title: context.ext.l10n.errors.sendLogsButton,
                              onChanged: (value) => _attachLogs.value = value,
                            ) */ CupertinoListTile(
                                  title: Text(Localization.of(context).bugReportAttachLogsToggleLabel),
                                  additionalInfo: UISwitch(
                                    value: value,
                                    onChanged: (value) => _attachLogs.value = value,
                                  ),
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: theme.uiTheme.size.offset.regular),
                      // --- Send report button --- //
                      SizedBox(
                        width: double.infinity,
                        child: ListenableBuilder(
                          listenable: Listenable.merge([_messageController, _attachLogs]),
                          builder: (context, _) => BugReportButton.filled(
                            route: 'BugReportDialog',
                            loading: _loading,
                            attachLogs: _attachLogs.value,
                            message: _messageController.text,
                            text: Localization.of(context).bugReportSubmitActionLabel,
                            onPressed: () => _loading.value = true,
                            onSucceeded: () {
                              _loading.value = false;
                              Navigator.of(context, rootNavigator: true).maybePop<void>();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: theme.uiTheme.size.offset.regular),
              // --- Enable/Disable shake --- //
              ListTile(
                contentPadding: CommonPadding.of(context),
                visualDensity: .compact,
                dense: true,
                title: Text(
                  Localization.of(context).bugReportShakeToReportToggleLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.2),
                ),
                trailing: ValueListenableBuilder<bool>(
                  valueListenable: _useOnShake,
                  builder: (context, value, _) => Switch.adaptive(
                    value: value,
                    onChanged: (value) {
                      context.ext.dependencies.database.setKey(BugReportDialog.useOnShakeKey, value);
                      _useOnShake.value = value;
                    },
                  ),
                ),
              ),
              Padding(
                padding: CommonPadding.of(context),
                child: Text(Localization.of(context).bugReportShakeToReportToggleHint, style: theme.textTheme.labelSmall),
              ),
              SizedBox(
                height: CommonBottomSpacer.keyboardIsOpenOf(context)
                    ? CommonBottomSpacer.keyboardOf(context) + theme.uiTheme.size.offset.regular
                    : CommonBottomSpacer.heightOf(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
