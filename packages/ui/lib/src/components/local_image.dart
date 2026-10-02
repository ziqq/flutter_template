import 'dart:typed_data';

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';

/// Displays native, browser, or in-memory image content through [XFile].
class UILocalImage extends StatefulWidget {
  const UILocalImage({
    required this.file,
    required this.placeholder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.sourceRect,
    super.key,
  });

  final XFile file;
  final Widget placeholder;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Optional crop rectangle in decoded source-image pixels.
  final Rect? sourceRect;

  @override
  State<UILocalImage> createState() => _UILocalImageState();
}

class _UILocalImageState extends State<UILocalImage> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.file.readAsBytes();
  }

  @override
  void didUpdateWidget(covariant UILocalImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.file, widget.file)) _bytes = widget.file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: _bytes,
    builder: (context, snapshot) {
      final bytes = snapshot.data;
      if (snapshot.connectionState != ConnectionState.done || snapshot.hasError || bytes == null || bytes.isEmpty) {
        return widget.placeholder;
      }
      if (widget.sourceRect == null) {
        return Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (_, _, _) => widget.placeholder,
        );
      }
      return ExtendedImage.memory(
        bytes,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadStateChanged: (state) => switch (state.extendedImageLoadState) {
          LoadState.loading || LoadState.failed => widget.placeholder,
          LoadState.completed => ExtendedRawImage(
            image: state.extendedImageInfo?.image,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            sourceRect: widget.sourceRect,
          ),
        },
      );
    },
  );
}
