import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:example/src/common/widgets/preview_section.dart';
import 'package:ui/ui.dart';

/// Exercises the editor with an in-memory image without picker permissions.
class MediaPreview extends StatefulWidget {
  const MediaPreview({super.key});

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  UIMediaSelection? _selection;
  Future<XFile>? _file;
  bool _opening = false;
  String? _error;

  Future<void> _edit(UIImageEditorType type) async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      final file = await (_file ??= _createImage());
      if (!mounted) return;
      final crop = await Navigator.of(context).push<Rect>(
        MaterialPageRoute<Rect>(
          fullscreenDialog: true,
          builder: (_) => UIImageEditorScreen(file: file, imageEditorType: type),
        ),
      );
      if (mounted && crop != null) setState(() => _selection = UIMediaSelection(file: file, crop: crop));
    } on Object catch (error) {
      _file = null;
      if (mounted) setState(() => _error = 'Could not open editor: ${error.runtimeType}');
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<XFile> _createImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    for (var x = 0; x < 6; x++) {
      for (var y = 0; y < 4; y++) {
        paint.color = Color.fromARGB(255, 40 + x * 35, 40 + y * 50, 180);
        canvas.drawRect(Rect.fromLTWH(x * 100, y * 100, 100, 100), paint);
      }
    }
    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(600, 400);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) throw StateError('Could not encode preview image.');
        return XFile.fromData(data.buffer.asUint8List(), name: 'crop-preview.png', mimeType: 'image/png');
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = _selection;
    return PreviewSection(
      title: 'XFile image crop',
      child: Padding(
        padding: EdgeInsets.all(Theme.of(context).uiTheme.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: _opening ? null : () => _edit(UIImageEditorType.rectOrSquare),
                  child: const Text('Rectangular crop'),
                ),
                TextButton(
                  onPressed: _opening ? null : () => _edit(UIImageEditorType.avatar),
                  child: const Text('Avatar crop'),
                ),
              ],
            ),
            if (_error case String error) Text(error),
            if (selection != null) ...[
              Text('Source: 600 × 400 px; crop: ${selection.crop}'),
              const Text('The source file is unchanged; crop encoding belongs to the caller.'),
              UILocalImage(
                file: selection.file,
                width: 240,
                height: 160,
                fit: BoxFit.contain,
                placeholder: const SizedBox(width: 240, height: 160),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
