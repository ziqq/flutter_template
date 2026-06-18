import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show ClipboardData, Clipboard, HapticFeedback;
import 'package:flutter_template_name/src/common/constant/pubspec.yaml.g.dart';
import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/model/dependencies.dart';
import 'package:flutter_template_name/src/common/widget/common_back_button.dart';
import 'package:flutter_template_name/src/common/widget/common_bottom_spacer.dart';
import 'package:flutter_template_name/src/common/widget/common_padding.dart';
import 'package:flutter_template_name/src/feature/developer/widget/logs_screen.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// {@template developer_screen}
/// DeveloperInfoScreen widget.
/// {@endtemplate}
class DeveloperInfoScreen extends StatelessWidget {
  /// {@macro developer_screen}
  const DeveloperInfoScreen({super.key});

  /// Show the developer screen
  /* static Future<void> show(BuildContext context) => Navigator.of(
    context,
    rootNavigator: true,
  ).push<void>(MaterialPageRoute<void>(builder: (context) => const DeveloperInfoScreen())); */

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.uiTheme.color.background,
      appBar: CupertinoNavigationBar(
        border: const Border(),
        padding: .zero,
        leading: const CommonBackButton(),
        backgroundColor: theme.uiTheme.color.background,
        middle: UIText.titleMedium(l10n.developerTitle),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          // --- Authentication --- //
          _GroupSeparator(title: l10n.developerSectionAuthenticationTitle),
          _OpenUriTile(title: l10n.profileTitle, description: l10n.developerUserCurrentInfoDescription),
          _OpenUriTile(
            title: l10n.developerUserRefreshSessionTitle,
            description: l10n.developerUserRefreshSessionDescription,
            onTap: () {} /* () => AuthenticationScope.refresh(
              context,
              onDone: () => AnimatedCheckIcon.dismiss(),
              onSucceeded: (_) => AnimatedCheckIcon.succeeded(context),
              onProcessing: () => AnimatedCheckIcon.processing(context),
              onError: (e) => AnimatedCheckIcon.error(context, message: ErrorUtil.formatMessage(e)),
            ).ignore() */,
          ),
          _OpenUriTile(title: l10n.authLogoutActionLabel, description: l10n.developerUserCurrentLogoutDescription),
          SliverPadding(
            padding: CommonPadding.of(context).copyWith(bottom: theme.uiTheme.padding, top: theme.uiTheme.padding),
            sliver: const SliverToBoxAdapter(child: SizedBox(height: 48, child: Placeholder())),
          ),

          // --- Application information --- //
          _GroupSeparator(title: l10n.developerSectionApplicationTitle),
          const _ShowApplicationInfoTile(),
          const _ShowLicensePageTile(),
          const _ShowApplicationDependenciesTile(),
          const _ShowApplicationDevDependenciesTile(),
          const _ShowLogsScreenTile(),

          // --- Navigation --- //
          _GroupSeparator(title: l10n.developerSectionNavigationTitle),
          const _ResetNavigationTile(),

          // --- Database --- //
          _GroupSeparator(title: l10n.developerSectionDatabaseTitle),
          const _ViewDatabaseTile(),
          const _ClearDatabaseTile(),

          // --- Useful links --- //
          _GroupSeparator(title: l10n.developerSectionUsefulLinksTitle),
          const _OpenUriTile(title: 'Flutter', description: 'Flutter website', uri: 'https://flutter.dev'),
          const _OpenUriTile(title: 'Flutter API', description: 'Framework API', uri: 'https://api.flutter.dev'),
          const _OpenUriTile(title: 'Portal', description: 'User portal'),
          const _OpenUriTile(
            title: 'Tasks',
            description: 'Tasks tracker',
            uri: 'https://github.com/user_or_org_name/flutter_template_name/issues',
          ),
          const _OpenUriTile(
            title: 'Repository',
            description: 'Project repository',
            uri: 'https://github.com/user_or_org_name/flutter_template_name',
          ),
          const _OpenUriTile(
            title: 'Pull requests',
            description: 'Pull requests list',
            uri: 'https://github.com/user_or_org_name/flutter_template_name/pulls',
          ),
          const _OpenUriTile(
            title: 'Jenkins',
            description: 'CI/CD pipeline',
            uri: 'https://github.com/user_or_org_name/flutter_template_name/actions',
          ),
          const _OpenUriTile(
            title: 'Figma',
            description: 'Designs system',
            uri:
                'https://www.figma.com/file/mpLFLLHDJhlXzMWxXrjout/AppOrOrgName-APP?type=design&node-id=Theme.of(context).uiTheme.padding512-1908&mode=design&t=MAqLDvCotcGBEFno-0',
          ),
          const _OpenUriTile(
            title: 'Firebase',
            description: 'Firebase console',
            uri:
                'https://console.firebase.google.com/u/1/project/beautyboxru---ga4/analytics/app/android:ru.beautybox.twa/overview',
          ),
          const _OpenUriTile(
            title: 'Sentry',
            description: 'Sentry console',
            uri:
                'https://AppOrOrgName.sentry.io/issues/?environment=prod&environment=production&project=4508914111217745&query=&referrer=issue-list&statsPeriod=7d',
          ),

          const CommonBottomSpacer.sliver(),
        ],
      ),
    );
  }
}

class _GroupSeparator extends StatelessWidget {
  const _GroupSeparator({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: CommonPadding.of(context),
    sliver: SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: Row(
          crossAxisAlignment: .center,
          mainAxisSize: .max,
          children: <Widget>[
            Text(
              title,
              maxLines: 1,
              overflow: .ellipsis,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1, fontWeight: FontWeight.w600),
            ),
            Expanded(child: Divider(indent: Theme.of(context).uiTheme.padding)),
          ],
        ),
      ),
    ),
  );
}

class _CopyTile extends StatelessWidget {
  const _CopyTile({required this.title, this.subtitle, this.content});

  final String title;
  final String? subtitle;
  final String? content;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: .zero,
    title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
    // Add QR code generation
    subtitle: subtitle != null
        ? Text(subtitle!, maxLines: 1, overflow: .ellipsis, style: Theme.of(context).textTheme.bodySmall)
        : null,
    onTap: () {
      Clipboard.setData(ClipboardData(text: content ?? (subtitle == null ? title : '$title: $subtitle')));
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(Localization.of(context).commonCopiedMessage), duration: const Duration(seconds: 3)),
        );
    },
  );
}

class _ShowApplicationInfoTile extends StatelessWidget {
  const _ShowApplicationInfoTile();

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return SliverPadding(
      padding: CommonPadding.of(context),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          contentPadding: .zero,
          title: Text(l10n.developerApplicationInfoTitle, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(
            l10n.developerApplicationInfoOpenDescription,
            maxLines: 1,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => showDialog<void>(
            context: context,
            builder: (context) => AboutDialog(
              applicationName: Pubspec.name,
              applicationVersion: Pubspec.version.representation,
              applicationIcon: const SizedBox.square(dimension: 64, child: Icon(Icons.apps, size: 64)),
              children: <Widget>[
                _CopyTile(title: l10n.commonNameLabel, subtitle: Pubspec.name, content: Pubspec.name),
                _CopyTile(
                  title: l10n.commonVersionLabel,
                  subtitle: Pubspec.version.representation,
                  content: Pubspec.version.representation,
                ),
                const _CopyTile(title: 'Description', subtitle: Pubspec.description, content: Pubspec.description),
                const _CopyTile(title: 'Homepage', subtitle: Pubspec.homepage, content: Pubspec.homepage),
                const _CopyTile(title: 'Repository', subtitle: Pubspec.repository, content: Pubspec.repository),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowLicensePageTile extends StatelessWidget {
  const _ShowLicensePageTile();

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: CommonPadding.of(context),
    sliver: SliverToBoxAdapter(
      child: ListTile(
        dense: true,
        contentPadding: .zero,
        title: Text(
          MaterialLocalizations.of(context).viewLicensesButtonLabel,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          MaterialLocalizations.of(context).licensesPageTitle,
          maxLines: 1,
          overflow: .ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () => showLicensePage(
          context: context,
          applicationName: Pubspec.name,
          applicationVersion: Pubspec.version.representation,
          applicationIcon: const SizedBox.square(dimension: 64, child: Icon(Icons.apps, size: 64)),
          useRootNavigator: true,
        ),
      ),
    ),
  );
}

class _ShowApplicationDependenciesTile extends StatelessWidget {
  const _ShowApplicationDependenciesTile();

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return SliverPadding(
      padding: CommonPadding.of(context),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          contentPadding: .zero,
          title: Text(l10n.developerDependenciesTitle, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(
            l10n.developerDependenciesOpenDescription,
            maxLines: 1,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => showDialog<void>(
            context: context,
            builder: (context) => Dialog(
              insetPadding: const .all(64),
              alignment: Alignment.center,
              child: Padding(
                padding: .all(Theme.of(context).uiTheme.padding),
                child: SizedBox(
                  width: 480,
                  child: Column(
                    mainAxisSize: .min,
                    children: <Widget>[
                      Text(
                        l10n.developerDependenciesTitle,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: Theme.of(context).uiTheme.padding),
                      Wrap(
                        children: <Widget>[
                          for (final d in Pubspec.dependencies.entries)
                            Padding(
                              padding: const .all(4),
                              child: Chip(label: Text('${d.key}: ${d.value}')),
                            ),
                        ],
                      ),
                      SizedBox(height: Theme.of(context).uiTheme.padding),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowApplicationDevDependenciesTile extends StatelessWidget {
  const _ShowApplicationDevDependenciesTile();

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return SliverPadding(
      padding: CommonPadding.of(context),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          contentPadding: .zero,
          title: Text(l10n.developerDevDependenciesTitle, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(
            l10n.developerDevDependenciesOpenDescription,
            maxLines: 1,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => showDialog<void>(
            context: context,
            builder: (context) => Dialog(
              insetPadding: const .all(64),
              alignment: Alignment.center,
              child: Padding(
                padding: .all(Theme.of(context).uiTheme.padding),
                child: SizedBox(
                  width: 480,
                  child: Column(
                    mainAxisSize: .min,
                    children: <Widget>[
                      Text(
                        l10n.developerDevDependenciesTitle,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: Theme.of(context).uiTheme.padding),
                      Wrap(
                        children: <Widget>[
                          for (final d in Pubspec.devDependencies.entries)
                            Padding(
                              padding: const .all(4),
                              child: Chip(label: Text('${d.key}: ${d.value}')),
                            ),
                        ],
                      ),
                      SizedBox(height: Theme.of(context).uiTheme.padding),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowLogsScreenTile extends StatelessWidget {
  const _ShowLogsScreenTile();

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return SliverPadding(
      padding: CommonPadding.of(context),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          contentPadding: .zero,
          title: Text(l10n.developerLogsTitle, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(
            l10n.developerLogsOpenDescription,
            maxLines: 1,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => Logs$Dialog.show(context).ignore(),
        ),
      ),
    );
  }
}

class _ResetNavigationTile extends StatelessWidget {
  const _ResetNavigationTile();

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return SliverPadding(
      padding: CommonPadding.of(context),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          contentPadding: .zero,
          title: Text(l10n.developerNavigationResetTitle, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(
            l10n.developerNavigationResetDescription,
            maxLines: 1,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

class _ViewDatabaseTile extends StatelessWidget {
  const _ViewDatabaseTile();

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return SliverPadding(
      padding: CommonPadding.of(context),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          contentPadding: .zero,
          title: Text(l10n.developerDatabaseOpenTitle, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(
            l10n.developerDatabaseOpenDescription,
            maxLines: 1,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => showDialog<void>(
            context: context,
            builder: (context) => Dialog(child: DriftDbViewer(Dependencies.of(context).database)),
          ),
        ),
      ),
    );
  }
}

class _ClearDatabaseTile extends StatelessWidget {
  const _ClearDatabaseTile();

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return SliverPadding(
      padding: CommonPadding.of(context),
      sliver: SliverToBoxAdapter(
        child: ListTile(
          dense: true,
          contentPadding: .zero,
          title: Text(l10n.developerDatabaseDropTitle, style: Theme.of(context).textTheme.bodyLarge),
          subtitle: Text(
            l10n.developerDatabaseDropDescription,
            maxLines: 1,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () {
            final db = Dependencies.of(context).database;
            final messenger = ScaffoldMessenger.maybeOf(context);
            Future<void>(() async {
              await db.customStatement('PRAGMA foreign_keys = OFF');
              try {
                await db.batch((batch) {
                  // ignore: prefer_foreach
                  for (final table in db.allTables) batch.deleteAll(table);
                });
              } finally {
                await db.customStatement('PRAGMA foreign_keys = ON');
              }
            }).then<void>(
              (_) => messenger?.showSnackBar(
                SnackBar(
                  content: Text(l10n.developerDatabaseClearSuccessMessage),
                  duration: const Duration(seconds: 3),
                ),
              ),
              // ignore: inference_failure_on_untyped_parameter
              onError: (error) => messenger?.showSnackBar(
                SnackBar(
                  content: Text('${l10n.developerDatabaseClearFailureMessage}: $error'),
                  backgroundColor: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemRed,
                    context, // ignore: use_build_context_synchronously
                  ),
                  duration: const Duration(seconds: 3),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OpenUriTile extends StatelessWidget {
  const _OpenUriTile({
    required this.title,
    required this.description,
    this.uri,
    this.onTap,
    super.key, // ignore: unused_element_parameter
  });

  final String title;
  final String description;
  final String? uri;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: CommonPadding.of(context),
      sliver: SliverToBoxAdapter(
        child: Opacity(
          opacity: onTap == null && uri == null ? 0.5 : 1,
          child: ListTile(
            dense: true,
            contentPadding: .zero,
            title: Text(title, style: theme.textTheme.bodyLarge),
            subtitle: Text(description, maxLines: 1, overflow: .ellipsis, style: theme.textTheme.bodySmall),
            onTap:
                onTap ??
                (uri == null
                    ? null
                    : () {
                        HapticFeedback.heavyImpact().ignore();
                        launchUrlString(uri!).ignore();
                      }),
          ),
        ),
      ),
    );
  }
}
