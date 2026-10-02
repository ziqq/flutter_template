import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

class AvatarPreview extends StatefulWidget {
  const AvatarPreview({super.key});

  @override
  State<AvatarPreview> createState() => _AvatarPreviewState();
}

class _AvatarPreviewState extends State<AvatarPreview> {
  late final Future<XFile> _first = _createFile(Colors.blue, Colors.orange);
  late final Future<XFile> _second = _createFile(Colors.green, Colors.purple);
  bool _alternate = false;

  Future<XFile> _createFile(Color left, Color right) async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..drawRect(const Rect.fromLTWH(0, 0, 60, 80), Paint()..color = left)
      ..drawRect(const Rect.fromLTWH(60, 0, 60, 80), Paint()..color = right);
    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(120, 80);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) throw StateError('Could not encode avatar preview.');
        return XFile.fromData(data.buffer.asUint8List(), name: 'avatar-preview.png', mimeType: 'image/png');
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => PreviewSection(
    title: 'Typed avatars and contrast',
    child: Padding(
      padding: EdgeInsets.all(Theme.of(context).uiTheme.size.offset.regular),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          const Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              UIAvatar(name: 'Anton Ustinoff', size: 64, status: 'done'),
              UIAvatarWithLoader(name: 'Loading avatar', size: 64, processing: true),
              UIAvatar.circle(name: '👩‍💻 Developer', size: 64),
              UIAvatar.circle(size: 64, semanticLabel: 'Fallback avatar'),
              UIAvatar(source: UIImageSource.asset('assets/avatar.svg'), size: 64, semanticLabel: 'SVG avatar'),
            ],
          ),
          FutureBuilder<XFile>(
            future: _alternate ? _second : _first,
            builder: (context, snapshot) {
              final file = snapshot.data;
              if (snapshot.connectionState != ConnectionState.done || file == null) return const SizedBox(height: 64);
              return Wrap(
                spacing: 16,
                children: [
                  UIAvatar(source: UIImageSource.local(file), size: 64, semanticLabel: 'Local XFile avatar'),
                  UIAvatarWithLoader(
                    source: UIImageSource.local(file),
                    size: 64,
                    semanticLabel: 'Editable XFile avatar',
                    onPick: () async => UIMediaSelection(file: await _second, crop: const Rect.fromLTWH(60, 0, 60, 80)),
                    onDelete: () {},
                  ),
                  UIAvatar.circle(
                    source: UIImageSource.local(file),
                    sourceRect: const Rect.fromLTWH(60, 0, 60, 80),
                    size: 64,
                    semanticLabel: 'Cropped XFile avatar',
                  ),
                ],
              );
            },
          ),
          UIButton.secondary(
            onPressed: () => setState(() => _alternate = !_alternate),
            child: const Text('Swap same-name memory files'),
          ),
          ColoredBox(
            color: const Color(0xff777777),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Contrast-aware foreground',
                style: TextStyle(color: UIColorUtil.contrastingForegroundColor(const Color(0xff777777))),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
