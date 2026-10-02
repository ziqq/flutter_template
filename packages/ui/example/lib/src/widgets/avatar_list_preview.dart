import 'package:example/src/common/widgets/component_preview_group.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

class AvatarListPreview extends StatelessWidget {
  const AvatarListPreview({super.key});
  static const _sources = <UIImageSource?>[UIImageSource.asset('assets/avatar.svg'), null, null, null, null];

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Avatar collections',
    child: Padding(
      padding: PreviewSection.contentPaddingOf(context),
      child: ComponentPreviewGroup(
        title: 'Typed sources and hidden count',
        description: 'Uses the same UIImageSource API as UIAvatar; directional overlap follows RTL.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            const UIAvatarList(avatars: _sources, avatarSize: 48, semanticLabel: 'Five members'),
            const Directionality(
              textDirection: TextDirection.rtl,
              child: UIAvatarList(avatars: _sources, avatarSize: 48, semanticLabel: 'Five members, right-to-left'),
            ),
            UIAvatarList(avatars: _sources.take(2).toList(), avatarSize: 32, withCounter: false),
            const UIAvatarList(avatars: []),
          ],
        ),
      ),
    ),
  );
}
