import 'package:flutter_template_name/src/common/localization/localization.dart';
import 'package:flutter_template_name/src/common/widget/scaffold_padding.dart';
import 'package:flutter_template_name/src/feature/authentication/widget/log_out_button.dart';
import 'package:ui/ui.dart';

/// {@template profile_screen}
/// ProfileScreen widget.
/// {@endtemplate}
class ProfileScreen extends StatelessWidget {
  /// {@macro profile_screen}
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(title: Text(l10n.profile), pinned: true, floating: true, snap: true),
          SliverPadding(
            padding: ScaffoldPadding.of(context).copyWith(top: 16, bottom: 16),
            sliver: SliverList.list(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Shimmer(
                        size: const Size(128, 128),
                        color: Colors.grey[400],
                        backgroundColor: Colors.grey[100],
                        cornerRadius: 42,
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextPlaceholder(height: 16, width: 64),
                          SizedBox(height: 12),
                          Padding(padding: EdgeInsets.only(left: 8), child: TextPlaceholder(height: 14, width: 100)),
                          SizedBox(height: 8),
                          Padding(padding: EdgeInsets.only(left: 8), child: TextPlaceholder(height: 14, width: 128)),
                          SizedBox(height: 8),
                          Padding(padding: EdgeInsets.only(left: 8), child: TextPlaceholder(height: 14, width: 72)),
                          SizedBox(height: 8),
                          Padding(padding: EdgeInsets.only(left: 8), child: TextPlaceholder(height: 14, width: 92)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 68,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    isThreeLine: false,
                    title: Text(
                      l10n.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1),
                    ),
                    subtitle: const Text(
                      'John Doe',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(height: 1),
                    ),
                    trailing: const LogOutButton(),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 68,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.settings)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    isThreeLine: false,
                    title: Text(
                      l10n.settings,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1),
                    ),
                    subtitle: Text(
                      l10n.settingsDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(height: 1),
                    ),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 24),
                const FormPlaceholder(title: false),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
