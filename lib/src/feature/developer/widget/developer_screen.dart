import 'package:flutter_template_name/src/common/localization/localization.dart';

import 'dart:async';

import 'package:control/control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template_name/src/common/constant/generated/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/app_pages.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:flutter_template_name/src/common/widget/common_back_button.dart';
import 'package:flutter_template_name/src/common/widget/common_padding.dart';
import 'package:flutter_template_name/src/common/widget/common_bottom_spacer.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/authentication_scope.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_template_name/src/feature/bug_report/bug_report_util.dart';
import 'package:flutter_template_name/src/feature/settings/controller/settings_controller.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:ui/ui.dart';

/// {@template developer_screen}
/// DeveloperScreen widget
/// {@endtemplate}
class DeveloperScreen extends StatefulWidget {
  /// {@macro developer_screen}
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DebugScreenState();

  /// Show the developer screen
}

/// State for widget [DeveloperScreen].
class _DebugScreenState extends State<DeveloperScreen> {
  /// Settings controller
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsScope.of(context);
  }

  Future<void> _onClearKVStorage() async {
    final dependencies = Dependencies.of(context);
    try {
      await dependencies.database.delete(dependencies.database.kvTbl).go();
      await dependencies.database.refresh();
      if (!mounted) return;
      await UI.showSnackBar(
        context: context,
        type: UISnackBarType.success,
        message: Localization.of(context).developerDatabaseClearSuccessMessage,
        useHapticFeedback: _settingsController.state.preferences.useHapticFeedback,
      );
    } on Object catch (error, stackTrace) {
      await ErrorUtil.logError(error, stackTrace);
      if (!mounted) return;
      await UI.showSnackBar(
        context: context,
        type: UISnackBarType.error,
        message: Localization.of(context).developerDatabaseClearFailureMessage,
      );
    }
  }

  /// Send logs action
  void _onSendLogs() {
    final dependencies = Dependencies.of(context);
    final l10n = Localization.of(context);
    final user = dependencies.authenticationController.state.user;
    final message = BugReportUtil.generateErrorMessage(
      user: user,
      route: 'DeveloperScreen',
      stackTrace: StackTrace.current,
      error: Exception('User #${user.id} initiated log sending'),
      message: 'User #${user.id} requested to send application logs.',
    );
    BugReportUtil.instance
        .sendReport(
          transport: .sentry,
          user: user,
          message: message,
          metadata: dependencies.metadata,
          onError: () => EasyLoading.showError(l10n.developerSendLogsMessageError),
          onSuccess: () => EasyLoading.showSuccess(l10n.developerSendLogsMessageSuccess),
          onProcess: () => EasyLoading.show(status: '${l10n.developerSendLogsMessage}...'),
        )
        .ignore();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uiTheme = theme.uiTheme;
    final l10n = Localization.of(context);
    final backgroundColor = uiTheme.color.secondaryBackground;
    final spacer = SliverToBoxAdapter(child: SizedBox(height: uiTheme.size.offset.regular));
    return UIAnnotateRegion(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          clipBehavior: .none,
          title: Text(l10n.developerTitle),
          backgroundColor: backgroundColor,
          leading: const CommonBackButton(),
        ),
        body: StateConsumer<SettingsController, SettingsState>(
          controller: _settingsController,
          buildWhen: (p, c) => p.preferences != c.preferences || p.settings != c.settings,
          builder: (context, state, _) => CupertinoScrollbar(
            child: CustomScrollView(
              slivers: <Widget>[
                spacer,

                // --- App section --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secondary(
                      children: <Widget>[
                        CupertinoListTile(
                          padding: CommonPadding.of(context),
                          title: Text(l10n.developerAppVersionLabel, style: theme.textTheme.bodyLarge),
                          additionalInfo: Text(
                            Pubspec.version.canonical,
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.uiTheme.color.textSecondary),
                          ),
                        ),
                        _DeveloperSelectRow(
                          title: l10n.developerShowLogsButton,
                          onTap: () => context.ext.navigator.push(const DeveloperLogsScreenPage()),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: uiTheme.size.offset.large)),

                // --- Developer section --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secondary(
                      footer: l10n.developerAdvancedOptionsHint,
                      children: <Widget>[
                        _DeveloperSwitchRow(
                          title: l10n.developerAdvancedOptionsUseDebugLabel,
                          value: state.preferences.useDebug,
                          onChanged: _settingsController.setUseDebug,
                        ),
                        _DeveloperSwitchRow(
                          title: l10n.developerAdvancedOptionsUseDeveloperModeLabel,
                          value: state.preferences.useDevelopment,
                          onChanged: _settingsController.setUseDevelompent,
                        ),
                        if (state.preferences.useDevelopment) ...[
                          _DeveloperSelectRow(
                            title: l10n.developerDeveloperInfoButton,
                            onTap: () => context.ext.navigator.push(const DeveloperInfoPage()),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                spacer,

                // --- Experimental features section --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secondary(
                      footer: l10n.developerExperimentalHint,
                      children: <Widget>[
                        _DeveloperSwitchRow(
                          title: l10n.developerAdvancedOptionsUseBetaLabel,
                          onChanged: _settingsController.setUseBeta,
                          value: state.preferences.useBeta,
                        ),
                        _DeveloperSwitchRow(
                          title: l10n.developerAdvancedOptionsUseExperementalLabel,
                          onChanged: _settingsController.setUseExpiremental,
                          value: state.preferences.useExpiremental,
                        ),
                      ],
                    ),
                  ),
                ),
                spacer,

                // --- IOS 26 features section --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secondary(
                      footer: l10n.developerIOS26LiquidThemeHint,
                      children: <Widget>[
                        _DeveloperSwitchRow(
                          title: l10n.developerIOS26LiquidThemeLabel,
                          value: state.preferences.useIOS26LiquidTheme,
                          onChanged: _settingsController.setUseIOS26LiquidTheme,
                        ),
                      ],
                    ),
                  ),
                ),
                spacer,

                // --- App functionality section --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secondary(
                      footer: l10n.developerAdvancedOptionsUseHapticFeedbackHint,
                      children: <Widget>[
                        _DeveloperSwitchRow(
                          title: l10n.developerAdvancedOptionsUseHapticFeedbackLabel,
                          onChanged: _settingsController.setUseHapticFeedback,
                          value: state.preferences.useHapticFeedback,
                        ),
                      ],
                    ),
                  ),
                ),
                spacer,

                // --- Clear key value storage section --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secondary(
                      footer: l10n.developerClearKVStorageHint,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: _onClearKVStorage,
                            alignment: Alignment.centerLeft,
                            padding: CommonPadding.of(context),
                            borderRadius: UIBorderRadius.regular(context),
                            child: Text(
                              l10n.developerClearKVStorageButton,
                              style: theme.textTheme.bodyLarge?.copyWith(color: uiTheme.color.accent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                spacer,

                // --- Send logs button --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secondary(
                      footer: Localization.of(context).bugReportAttachLogsHelpText,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: _onSendLogs,
                            alignment: Alignment.centerLeft,
                            padding: CommonPadding.of(context),
                            borderRadius: UIBorderRadius.regular(context),
                            child: Text(
                              l10n.developerSendLogsButton,
                              style: theme.textTheme.bodyLarge?.copyWith(color: uiTheme.color.accent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                spacer,

                // --- Logout all button --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secondary(
                      footer: l10n.developerLogoutHint,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: () => UI
                                .showCupertinoModal<void>(
                                  context: context,
                                  useRootNavigator: false,
                                  title: Text(l10n.developerLogoutSubtitle),
                                  cancelButtonText: Localization.of(context).cancelButton,
                                  actions: [
                                    CupertinoActionSheetAction(
                                      isDestructiveAction: true,
                                      onPressed: () {
                                        Navigator.of(context).pop<void>();
                                        AuthenticationScope.signOut(context).ignore();
                                      },
                                      child: Text(Localization.of(context).developerLogoutButton),
                                    ),
                                  ],
                                )
                                .ignore(),
                            alignment: Alignment.centerLeft,
                            padding: CommonPadding.of(context),
                            borderRadius: UIBorderRadius.regular(context),
                            child: Text(
                              l10n.developerLogoutButton,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: CupertinoDynamicColor.resolve(CupertinoColors.systemRed, context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: CommonBottomSpacer()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeveloperSwitchRow extends StatelessWidget {
  const _DeveloperSwitchRow({required this.title, required this.value, required this.onChanged});
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => CupertinoListTile(
    padding: CommonPadding.of(context),
    title: Text(title, maxLines: 3),
    trailing: UISwitch(value: value, onChanged: onChanged),
  );
}

class _DeveloperSelectRow extends StatelessWidget {
  const _DeveloperSelectRow({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => CupertinoListTile(
    padding: CommonPadding.of(context),
    title: Text(title, maxLines: 3),
    trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
    onTap: onTap,
  );
}
