import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/generated/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/router/app_pages.dart';
import 'package:flutter_template_name/src/common/util/context_extension.dart';
import 'package:flutter_template_name/src/common/util/log_buffer.dart';
import 'package:flutter_template_name/src/common/widget/common_back_button.dart';
import 'package:flutter_template_name/src/common/widget/common_padding.dart';
import 'package:flutter_template_name/src/common/widget/common_bottom_spacer.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/authentication_scope.dart';
import 'package:flutter_template_name/src/feature/bug_report/widget/bug_report_dialog.dart';
import 'package:flutter_template_name/src/feature/settings/widget/settings_scope.dart';
import 'package:ui/ui.dart';

void _showActivityStatusOverlayGallery(BuildContext context) {
  final l10n = Localization.of(context);

  void show(VoidCallback action) {
    Navigator.of(context, rootNavigator: true).pop<void>();
    action();
  }

  UI
      .showCupertinoModal<void>(
        context: context,
        title: Text(l10n.developerActivityStatusOverlayTitle),
        message: Text(l10n.developerPreviewSelectStateDescription),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () => show(() {
              EasyLoading.show(status: l10n.developerProcessingPreviewLabel);
              Future<void>.delayed(const Duration(seconds: 2), EasyLoading.dismiss).ignore();
            }),
            child: Text(l10n.developerProcessingPreviewLabel),
          ),
          CupertinoActionSheetAction(
            onPressed: () => show(() => EasyLoading.showSuccess(l10n.developerSuccessPreviewLabel)),
            child: Text(l10n.developerSuccessPreviewLabel),
          ),
          CupertinoActionSheetAction(
            onPressed: () => show(() => EasyLoading.showError(l10n.developerErrorPreviewLabel)),
            child: Text(l10n.developerErrorPreviewLabel),
          ),
        ],
      )
      .ignore();
}

void _showSnackBarGallery(BuildContext context) {
  final useHapticFeedback = SettingsScope.userPreferencesOf(context, listen: false).useHapticFeedback;
  final l10n = Localization.of(context);

  void show(UISnackBarType type, String message) {
    Navigator.of(context, rootNavigator: true).pop<void>();
    UI.showSnackBar(context: context, type: type, useHapticFeedback: useHapticFeedback, message: message).ignore();
  }

  UI
      .showCupertinoModal<void>(
        context: context,
        title: Text(l10n.developerSnackbarGalleryTitle),
        message: Text(l10n.developerPreviewSelectStateDescription),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () => show(.success, l10n.developerSnackbarSuccessPreviewMessage),
            child: Text(l10n.developerSuccessPreviewLabel),
          ),
          CupertinoActionSheetAction(
            onPressed: () => show(.error, l10n.developerSnackbarErrorPreviewMessage),
            child: Text(l10n.developerErrorPreviewLabel),
          ),
        ],
      )
      .ignore();
}

/// {@template developer_screen}
/// DeveloperInfoScreen widget.
/// {@endtemplate}
class DeveloperInfoScreen extends StatelessWidget {
  /// {@macro developer_screen}
  const DeveloperInfoScreen({super.key});

  /// Show the developer screen

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = Localization.of(context);
    final user = AuthenticationScope.userOf(context);
    final titleTextStyle = theme.textTheme.bodyLarge?.copyWith(height: 1);
    final labelTextTyle = theme.textTheme.bodySmall?.copyWith(fontSize: 12);
    final subtitleTextStyle = theme.textTheme.bodySmall?.copyWith(height: 1);
    return Scaffold(
      backgroundColor: theme.uiTheme.color.secondaryBackground,
      appBar: AppBar(
        clipBehavior: .none,
        leading: const CommonBackButton(),
        title: UIText.headlineMedium(l10n.developerDeveloperInfoButton),
        backgroundColor: theme.uiTheme.color.secondaryBackground,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          // --- Authentication --- //
          SliverToBoxAdapter(
            child: Padding(
              padding: CommonPadding.of(context),
              child: UIListSection.secondary(
                header: l10n.developerAccountAndDeviceSectionTitle.toUpperCase(),
                children: <Widget>[
                  _ExpansionTile(
                    title: l10n.developerUserIDLabel,
                    icon: Icons.fingerprint_rounded,
                    subtitle: l10n.developerUserInformationDescription,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          style: labelTextTyle,
                          children: <InlineSpan>[TextSpan(text: user.id ?? '—')],
                        ),
                      ),
                    ],
                  ),
                  _ExpansionTile(
                    title: l10n.developerFcmPushTokenLabel,
                    icon: CupertinoIcons.info,
                    subtitle: l10n.developerFcmPushTokenDescription,
                    children: <Widget>[
                      FutureBuilder<String?>(
                        future: Firebase.apps.isEmpty ? Future<String?>.value() : FirebaseMessaging.instance.getToken(),
                        builder: (context, snapshot) => RichText(
                          text: TextSpan(
                            style: theme.textTheme.labelSmall?.copyWith(fontSize: 12),
                            children: <InlineSpan>[
                              TextSpan(text: snapshot.data ?? l10n.developerNoTokenAvailableLabel),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // SliverPadding(
          //   padding: CommonPadding.of(context).copyWith(bottom: theme.uiTheme.padding, top: theme.uiTheme.padding),
          //   sliver: const SliverToBoxAdapter(child: SizedBox(height: 48, child: Placeholder())),
          // ),

          // --- Application --- //
          SliverToBoxAdapter(
            child: Padding(
              padding: CommonPadding.of(context),
              child: UIListSection.secondary(
                header: l10n.developerApplicationSectionTitle.toUpperCase(),
                children: <Widget>[
                  Builder(
                    builder: (context) {
                      final metadata = Dependencies.of(context).metadata;
                      final view = View.of(context);
                      String formatDateTime(DateTime dateTime) => DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
                      return _ExpansionTile(
                        icon: CupertinoIcons.info,
                        title: l10n.developerAppMetadataTitle,
                        subtitle: l10n.developerAppMetadataDescription,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              style: labelTextTyle,
                              children: <InlineSpan>[
                                TextSpan(text: '${l10n.developerMetadataEnvironmentLabel}: ${Config.environment}\n'),
                                TextSpan(text: '${l10n.developerAppVersionLabel}: ${Pubspec.version.representation}\n'),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataBuildTimestampLabel}: '
                                      '${formatDateTime(metadata.appBuildTimestamp)}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataLaunchedTimestampLabel}: '
                                      '${formatDateTime(metadata.appLaunchedTimestamp)}\n',
                                ),
                                TextSpan(
                                  text: '${l10n.developerMetadataOperationSystemLabel}: ${metadata.operatingSystem}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataOperationSystemManufacturerLabel}: '
                                      '${metadata.operatingSystemManufacturer}\n',
                                ),
                                TextSpan(
                                  text: '${l10n.developerMetadataPlatformVersionLabel}: ${metadata.platformVersion}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataGoogleMobileServicesLabel}: ${metadata.hasGmsServices}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataHuaweiMobileServicesLabel}: ${metadata.hasHmsServices}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataPlatformLocalesLabel}: '
                                      '${WidgetsBinding.instance.platformDispatcher.locales.join(', ')}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataPlatformLocaleLabel}: '
                                      '${WidgetsBinding.instance.platformDispatcher.locale}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataSupportedLocalesLabel}: ${Localization.supportedLocales.join(', ')}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataCurrentLocaleLabel}: ${Localizations.localeOf(context)}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataBuildModeLabel}: '
                                      '${metadata.isRelease ? l10n.developerMetadataBuildModeReleaseLabel : l10n.developerMetadataBuildModeDebugLabel}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataPlatformBrightnessLabel}: ${Theme.of(context).brightness.name}\n',
                                ),

                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataDisplaysLabel}: ${PlatformDispatcher.instance.views.length}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataDeviceScreenSizeLabel}: ${metadata.deviceScreenSize}\n',
                                ),
                                TextSpan(
                                  text: '${l10n.developerMetadataDevicePixelRatioLabel}: ${view.devicePixelRatio}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataPhysicalSizeLabel}: ${view.physicalSize.width.toStringAsFixed(2)} x '
                                      '${view.physicalSize.height.toStringAsFixed(2)}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataLogicalSizeLabel}: ${view.physicalSize.width / view.devicePixelRatio} x '
                                      '${view.physicalSize.height / view.devicePixelRatio}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataPaddingLabel}: l${view.viewPadding.left.toInt()} '
                                      't${view.viewPadding.top.toInt()} r${view.viewPadding.right.toInt()} '
                                      'b${view.viewPadding.bottom.toInt()}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataViewInsetsLabel}: l${view.viewInsets.left.toInt()} '
                                      't${view.viewInsets.top.toInt()} r${view.viewInsets.right.toInt()} '
                                      'b${view.viewInsets.bottom.toInt()}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataSystemGestureInsetsLabel}: l${view.systemGestureInsets.left.toInt()} '
                                      't${view.systemGestureInsets.top.toInt()} r${view.systemGestureInsets.right.toInt()} '
                                      'b${view.systemGestureInsets.bottom.toInt()}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataTextScaleFactorLabel}: ${MediaQuery.textScalerOf(context)}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataDisplayFeaturesLabel}: ${l10n.developerNoDisplayFeaturesLabel}\n',
                                ),
                                TextSpan(text: '${l10n.developerMetadataCPULabel}: ${metadata.processorsCount}\n'),
                                TextSpan(text: '${l10n.developerMetadataApiURLLabel}: ${Config.apiBaseUrl}\n'),
                                TextSpan(
                                  text: '${l10n.developerMetadataSentryLabel}: ${Config.sentryDSN.isNotEmpty}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerMetadataYandexMetricaLabel}: ${Config.appMetricaKey.isNotEmpty}\n',
                                ),
                                TextSpan(
                                  text:
                                      '${l10n.developerLogsLabel}: ${LogBuffer.instance.logs.length} / ${LogBuffer.bufferLimit}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  CupertinoListTile(
                    onTap: () => context.ext.navigator.push(const DeveloperInitializationStatsPage()),
                    padding: CommonPadding.of(context),
                    leading: const Icon(CupertinoIcons.chart_pie),
                    leadingToTitle: _ExpansionTile.leadingToTitle,
                    title: Text(l10n.developerInitializationStatsTitle, style: titleTextStyle),
                    subtitle: Text(l10n.developerInitializationStatsDescription, style: subtitleTextStyle),
                    trailing: Icon(
                      CupertinoIcons.chevron_right,
                      size: theme.uiTheme.size.icon.extraSmall,
                      color: CupertinoDynamicColor.resolve(CupertinoColors.inactiveGray, context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- UI Flows --- //
          SliverToBoxAdapter(
            child: Padding(
              padding: CommonPadding.of(context),
              child: UIListSection.secondary(
                header: l10n.developerUiFlowsSectionTitle.toUpperCase(),
                children: <Widget>[
                  CupertinoListTile(
                    key: const ValueKey<String>('developer_analytics_data_sending'),
                    padding: CommonPadding.of(context),
                    leading: const Icon(CupertinoIcons.chart_bar),
                    leadingToTitle: _ExpansionTile.leadingToTitle,
                    title: Text(l10n.developerAnalyticsDataSendingLabel, style: titleTextStyle),
                    subtitle: Text(l10n.developerAnalyticsDataSendingDescription, style: subtitleTextStyle),
                    additionalInfo: Builder(
                      builder: (context) {
                        final preferences = SettingsScope.userPreferencesOf(context);
                        return UISwitch(
                          value: preferences.analyticsDataSendingEnabled,
                          onChanged: (enabled) => SettingsScope.of(context).setAnalyticsDataSendingEnabled(enabled),
                        );
                      },
                    ),
                  ),
                  CupertinoListTile(
                    padding: CommonPadding.of(context),
                    leading: const Icon(Icons.dark_mode_rounded),
                    leadingToTitle: _ExpansionTile.leadingToTitle,
                    title: Text(l10n.developerDarkModeLabel, style: titleTextStyle),
                    subtitle: Text(l10n.developerDarkModeDescription, style: subtitleTextStyle),
                    additionalInfo: Builder(
                      builder: (context) {
                        final themeMode = SettingsScope.themeModeOf(context);
                        return UISwitch(
                          value: themeMode == .dark,
                          onChanged: (_) => SettingsScope.setThemeMode(context, themeMode == .dark ? .light : .dark),
                        );
                      },
                    ),
                  ),

                  CupertinoListTile(
                    onTap: () => BugReportDialog.show(context).ignore(),
                    padding: CommonPadding.of(context),
                    leadingToTitle: _ExpansionTile.leadingToTitle,
                    leading: const Icon(Icons.bug_report_outlined),
                    title: Text(Localization.of(context).bugReportDialogTitle, style: titleTextStyle),
                    subtitle: Text(l10n.developerBugReportDialogDescription, style: subtitleTextStyle),
                  ),
                  CupertinoListTile(
                    onTap: () => _showActivityStatusOverlayGallery(context),
                    padding: CommonPadding.of(context),
                    leadingToTitle: _ExpansionTile.leadingToTitle,
                    leading: const Icon(Icons.motion_photos_on_outlined),
                    title: Text(l10n.developerActivityStatusOverlayTitle, style: titleTextStyle),
                    subtitle: Text(l10n.developerActivityStatusOverlayDescription, style: subtitleTextStyle),
                  ),
                  CupertinoListTile(
                    onTap: () => _showSnackBarGallery(context),
                    padding: CommonPadding.of(context),
                    leadingToTitle: _ExpansionTile.leadingToTitle,
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(l10n.developerSnackbarGalleryTitle, style: titleTextStyle),
                    subtitle: Text(l10n.developerSnackbarGalleryDescription, style: subtitleTextStyle),
                  ),

                  CupertinoListTile(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(Localization.of(context).developerConfirmationDialogTitle),
                        content: Text(Localization.of(context).developerConfirmationDialogDescription),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(Localization.of(context).cancelButton),
                          ),
                        ],
                      ),
                    ),
                    padding: CommonPadding.of(context),
                    leadingToTitle: _ExpansionTile.leadingToTitle,
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: Text(l10n.developerConfirmationDialogTitle, style: titleTextStyle),
                    subtitle: Text(l10n.developerConfirmationDialogDescription, style: subtitleTextStyle),
                  ),
                ],
              ),
            ),
          ),
          const CommonBottomSpacer.sliver(),
        ],
      ),
    );
  }
}

class _ExpansionTile extends StatefulWidget {
  const _ExpansionTile({
    required this.title,
    required this.subtitle,
    this.children = const <Widget>[],
    this.icon,
    this.onTap, // ignore: unused_element_parameter
    super.key, // ignore: unused_element_parameter
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Widget> children;

  /// The leading to title spacing for the expansion tile.
  static double leadingToTitle = 8.0;

  @override
  State<_ExpansionTile> createState() => _ExpansionTileState();
}

/// The state for the [_ExpansionTile] widget.
class _ExpansionTileState extends State<_ExpansionTile> {
  final ValueNotifier<bool> _expanded = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = SettingsScope.userPreferencesOf(context);
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: Material(
        child: ExpansionTile(
          backgroundColor: theme.uiTheme.color.onSecondaryBackground,
          collapsedIconColor: theme.uiTheme.color.textSecondary,
          onExpansionChanged: (v) => _expanded.value = v,
          iconColor: theme.uiTheme.color.textSecondary,
          enableFeedback: prefs.useHapticFeedback,
          tilePadding: CommonPadding.of(context),
          expandedAlignment: .centerLeft,
          visualDensity: .compact,
          childrenPadding: .only(
            left: theme.uiTheme.size.offset.regular,
            right: theme.uiTheme.size.offset.regular,
            bottom: theme.uiTheme.size.offset.regular,
          ),
          dense: true,
          leading: widget.icon != null
              ? Icon(widget.icon, color: theme.iconTheme.color, size: theme.uiTheme.size.icon.regular)
              : null,
          title: Text(widget.title, style: theme.textTheme.bodyLarge?.copyWith(height: 1.2)),
          subtitle: Text(
            widget.subtitle,
            maxLines: 1,
            overflow: .ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.2),
          ),
          trailing: ValueListenableBuilder<bool>(
            valueListenable: _expanded,
            builder: (_, expanded, _) => Icon(
              expanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
              size: theme.uiTheme.size.icon.extraSmall,
              color: CupertinoDynamicColor.resolve(CupertinoColors.inactiveGray, context),
            ),
          ),
          children: widget.children,
        ),
      ),
    );
  }
}
