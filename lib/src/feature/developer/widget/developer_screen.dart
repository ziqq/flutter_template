import 'dart:async';

import 'package:control/control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/router/app_navigator.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/common/widget/common_back_button.dart';
import 'package:flutter_template_name/src/common/widget/common_bottom_spacer.dart';
import 'package:flutter_template_name/src/common/widget/common_padding.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/authentication_scope.dart';
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
}

/// State for widget [DeveloperScreen].
class _DebugScreenState extends State<DeveloperScreen> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsScope.of(context);
  }

  /// Send logs action
  void _onSendLogs() {
    final dependencies = Dependencies.of(context);
    // final l10n = DeveloperLocalization.of(context);
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
          // onError: () => AnimatedCheckIcon.error(context, message: l10n.sendLogsMessageError),
          // onSuccess: () => AnimatedCheckIcon.succeeded(context, message: l10n.sendLogsMessageSuccess),
          // onProcess: () => AnimatedCheckIcon.processing(context, message: '${l10n.sendLogsMessage}...'),
        )
        .ignore();
  }

  /// Clear key-value storage action
  void _onKVStorageClear() {
    final dependencies = Dependencies.of(context);
    final user = dependencies.authenticationController.state.user;
    final key = '${Config.storageNamespace}.${user.id}.whats_app_notifications.promo_code';
    dependencies.database.removeAll();
    dependencies.sharedPreferences.remove(key);
    UI
        .showSnackBar(
          context: context,
          type: UISnackBarType.success,
          useHapticFeedback: context.ext.settings.useHapticFeedback(listen: false),
          message: Localization.of(context).developerStorageClearSuccessMessage,
        )
        .ignore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final theme = Theme.of(context);
    final backgroundColor = theme.uiTheme.color.secondaryBackground;
    final spacer = SliverToBoxAdapter(child: SizedBox(height: theme.uiTheme.size.offset.regular));
    return UIAnnotateRegion.secondary(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: CupertinoNavigationBar(
          padding: .zero,
          border: const Border(),
          backgroundColor: backgroundColor,
          leading: const CommonBackButton(),
          middle: UIText.titleMedium(l10n.developerTitle),
        ),
        body: StateConsumer<SettingsController, SettingsState>(
          controller: _controller,
          buildWhen: (p, c) => p.preferences != c.preferences || p.settings != c.settings,
          builder: (context, state, _) => CupertinoScrollbar(
            child: CustomScrollView(
              slivers: <Widget>[
                spacer,

                // --- App section --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secodary(
                      children: <Widget>[
                        CupertinoListTile(
                          padding: CommonPadding.of(context),
                          title: Text(l10n.developerAppVersionLabel, style: theme.textTheme.bodyLarge),
                          additionalInfo: Text(
                            Pubspec.version.canonical,
                            style: theme.textTheme.bodyLarge?.copyWith(color: theme.uiTheme.color.textSecondary),
                          ),
                        ),
                        /* UICupertinoFormRowSelect(
                          title: /* l10n.developerLogsOpenDescriptionButton */ 'Show logs',
                          showSuffix: false,
                          onTap: () => LogsScreen.show(context),
                        ), */
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: theme.uiTheme.size.offset.large)),

                // --- Developer section --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secodary(
                      textFooter: l10n.developerFeatureFlagsDescription,
                      children: <Widget>[
                        /* UICupertinoFormRow.withSwitch(
                          title: /* l10n.advancedOptionsUseDebug */ 'Use debug features',
                          value: state.preferences.useDebug,
                          onChanged: _controller.setUseDebug,
                        ), */
                        CupertinoListTile(
                          title: Text(l10n.developerToggleDebugFeaturesLabel),
                          additionalInfo: UISwitch(
                            value: state.preferences.useDebug,
                            onChanged: _controller.setUseDebug,
                          ),
                        ),
                        /* UICupertinoFormRow.withSwitch(
                          title: /* l10n.advancedOptionsUseDeveloperMode */ 'Use developer mode',
                          value: state.preferences.useDevelopment,
                          onChanged: _controller.setUseDevelompent,
                        ), */
                        CupertinoListTile(
                          title: Text(l10n.developerDeveloperModeToggleLabel),
                          additionalInfo: UISwitch(
                            value: state.preferences.useDevelopment,
                            onChanged: _controller.setUseDevelompent,
                          ),
                        ),
                        if (state.preferences.useDevelopment) ...[
                          /* UICupertinoFormRowSelect(
                            title: /* l10n.developerInfoOpenActionLabel */ 'Developer info',
                            showSuffix: false,
                            onTap: () => context.ext.navigator.push(const DeveloperInfoPage()),
                          ), */
                          CupertinoListTile(
                            title: Text(l10n.developerInfoOpenActionLabel),
                            additionalInfo: CupertinoButton(
                              padding: .zero,
                              onPressed: () => context.ext.navigator.push(const DeveloperInfoPage()),
                              child: const Icon(CupertinoIcons.forward, size: 16),
                            ),
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
                    child: UIListSection.secodary(
                      textFooter: l10n.developerToggleExperimentalFeaturesDescription,
                      children: <Widget>[
                        /* UICupertinoFormRow.withSwitch(
                          title: /* l10n.advancedOptionsUseBeta */ 'Use beta features',
                          onChanged: _controller.setUseBeta,
                          value: state.preferences.useBeta,
                        ), */
                        CupertinoListTile(
                          title: Text(l10n.developerToggleBetaFeaturesLabel),
                          additionalInfo: UISwitch(value: state.preferences.useBeta, onChanged: _controller.setUseBeta),
                        ),
                        /* UICupertinoFormRow.withSwitch(
                          title: /* l10n.advancedOptionsUseExperemental */ 'Use experimental features',
                          onChanged: _controller.setUseExpiremental,
                          value: state.preferences.useExpiremental,
                        ), */
                        CupertinoListTile(
                          title: Text(l10n.developerToggleExperimentalFeaturesLabel),
                          additionalInfo: UISwitch(
                            value: state.preferences.useExpiremental,
                            onChanged: _controller.setUseExpiremental,
                          ),
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
                    child: UIListSection.secodary(
                      textFooter: l10n.developerHapticFeedbackDescription,
                      children: <Widget>[
                        /* UICupertinoFormRow.withSwitch(
                          title: /* l10n.advancedOptionsUseHapticFeedback */ 'Use haptic feedback',
                          onChanged: _controller.setUseHapticFeedback,
                          value: state.preferences.useHapticFeedback,
                        ), */
                        CupertinoListTile(
                          title: Text(l10n.developerHapticFeedbackToggleLabel),
                          additionalInfo: UISwitch(
                            value: state.preferences.useHapticFeedback,
                            onChanged: _controller.setUseHapticFeedback,
                          ),
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
                    child: UIListSection.secodary(
                      textFooter: l10n.developerStorageClearDescription,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: _onKVStorageClear,
                            alignment: Alignment.centerLeft,
                            padding: CommonPadding.of(context),
                            borderRadius: UIBorderRadius.regular(context),
                            child: Text(
                              l10n.developerStorageClearActionLabel,
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.uiTheme.color.accent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                spacer,

                // --- Refresh FCM token button --- //
                SliverToBoxAdapter(
                  child: Padding(
                    padding: CommonPadding.of(context),
                    child: UIListSection.secodary(
                      textFooter: l10n.developerNotificationsRefreshDescription,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: () async {
                              /* try {
                                final id = context.ext.dependencies.authenticationController.state.user.id;
                                await context.ext.dependencies.authenticationRepository.reSubscribeToNotifications(
                                  skipCheckTimestamp: true,
                                  id: id,
                                );
                              } on Object catch (e, _) {
                                if (!context.mounted) return;
                                UI
                                    .showSnackBar(
                                      context: context,
                                      message: e.toString(),
                                      type: UISnackBarType.error,
                                      useHapticFeedback: context
                                          .ext
                                          .dependencies
                                          .settingsController
                                          .state
                                          .preferences
                                          .useHapticFeedback,
                                    )
                                    .ignore();
                              } */
                            },
                            alignment: Alignment.centerLeft,
                            padding: CommonPadding.of(context),
                            borderRadius: UIBorderRadius.regular(context),
                            child: Text(
                              l10n.developerNotificationsRefreshTitle,
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.uiTheme.color.accent),
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
                    child: UIListSection.secodary(
                      textFooter: l10n.developerLogsShareDescription,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: _onSendLogs,
                            alignment: Alignment.centerLeft,
                            padding: CommonPadding.of(context),
                            borderRadius: UIBorderRadius.regular(context),
                            child: Text(
                              l10n.developerLogsShareActionLabel,
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.uiTheme.color.accent),
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
                    child: UIListSection.secodary(
                      textFooter: l10n.developerSessionsLogoutAllDescription,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: () => UI
                                .showCupertinoModal<void>(
                                  context: context,
                                  useRootNavigator: false,
                                  title: Text(l10n.developerSessionsLogoutAllConfirmationMessage),
                                  cancelButtonText: l10n.commonCancelActionLabel,
                                  actions: [
                                    CupertinoActionSheetAction(
                                      isDestructiveAction: true,
                                      onPressed: () {
                                        // context.ext.dependencies.authenticationRepository.logoutFromAllDevices();
                                        Navigator.of(context).pop<void>();
                                        AuthenticationScope.signOut(
                                          context,
                                          // fromAllDevices: true,
                                          // useLogoutDialog: kDebugMode,
                                          // onProcessing: () => AnimatedCheckIcon.processing(
                                          //   context,
                                          //   message: '${l10n.logoutStatusLabel}...',
                                          // ),
                                          // onError: (error) => AnimatedCheckIcon.error(
                                          //   context,
                                          //   message: ErrorUtil.errorToString(context, error),
                                          // ),
                                          // onDone: AnimatedCheckIcon.dismiss,
                                          // onSucceeded: () {
                                          //   AnimatedCheckIcon.succeeded(context, message: l10n.logoutMessageSuccess);
                                          // },
                                        );
                                      },
                                      child: Text(l10n.authLogoutActionLabel),
                                    ),
                                  ],
                                )
                                .ignore(),
                            alignment: Alignment.centerLeft,
                            padding: CommonPadding.of(context),
                            borderRadius: UIBorderRadius.regular(context),
                            child: Text(
                              l10n.developerSessionsLogoutAllActionLabel,
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
                const CommonBottomSpacer.sliver(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
