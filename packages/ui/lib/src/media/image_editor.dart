import 'dart:typed_data';

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

export 'package:extended_image/extended_image.dart'
    show CropAspectRatios, EditorConfig, ExtendedImageEditorState, InitEditorConfigHandler;

/// Edits an [XFile] from a picker, native path, browser Blob, or memory.
///
/// Reading bytes on every platform also supports native [XFile.fromData].
/// The caller owns [editorKey] and supplies the crop configuration.
class UIImageEditor extends StatefulWidget {
  const UIImageEditor({
    required this.file,
    required this.editorKey,
    required this.initEditorConfigHandler,
    required this.width,
    required this.height,
    super.key,
  });

  final XFile file;
  final GlobalKey<ExtendedImageEditorState> editorKey;
  final InitEditorConfigHandler initEditorConfigHandler;
  final double width;
  final double height;

  @override
  State<UIImageEditor> createState() => _UIImageEditorState();
}

class _UIImageEditorState extends State<UIImageEditor> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.file.readAsBytes();
  }

  @override
  void didUpdateWidget(covariant UIImageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.file, widget.file)) _bytes = widget.file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: _bytes,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }
      final bytes = snapshot.data;
      if (snapshot.hasError || bytes == null || bytes.isEmpty) {
        return const Center(child: Icon(Icons.broken_image_outlined));
      }
      return ExtendedImage.memory(
        bytes,
        key: ObjectKey(widget.file),
        fit: BoxFit.contain,
        width: widget.width,
        height: widget.height,
        mode: ExtendedImageMode.editor,
        extendedImageEditorKey: widget.editorKey,
        initEditorConfigHandler: widget.initEditorConfigHandler,
        loadStateChanged: (state) => switch (state.extendedImageLoadState) {
          LoadState.loading => const Center(child: CircularProgressIndicator.adaptive()),
          LoadState.failed => const Center(child: Icon(Icons.broken_image_outlined)),
          LoadState.completed => null,
        },
      );
    },
  );
}
