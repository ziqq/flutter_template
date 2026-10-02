import 'package:cross_file/cross_file.dart' show XFile;
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ui/ui.dart';

/// Selects a rectangular crop or a square crop with an avatar preview mask.
enum UIImageEditorType { avatar, rectOrSquare }

/// Returns a confirmed [Rect] in source-image pixels through [Navigator.pop].
///
/// Cancellation returns `null`; confirmation calls [onChanged] once. The
/// original [file] remains unchanged: callers own encoding or uploading the
/// selected rectangle. The circular avatar mask does not encode a round image.
class UIImageEditorScreen extends StatefulWidget {
  const UIImageEditorScreen({
    required this.file,
    this.onChanged,
    this.useHapticFeedback = true,
    this.aspectRatio = CropAspectRatios.ratio1_1,
    this.imageEditorType = UIImageEditorType.rectOrSquare,
    super.key,
  }) : assert(aspectRatio > 0 && aspectRatio < double.infinity, 'Crop aspect ratio must be positive and finite.');

  final XFile file;
  final ValueChanged<Rect>? onChanged;
  final bool useHapticFeedback;
  final double aspectRatio;
  final UIImageEditorType imageEditorType;

  @override
  State<UIImageEditorScreen> createState() => _UIImageEditorScreenState();
}

class _UIImageEditorScreenState extends State<UIImageEditorScreen> {
  final _editorKey = GlobalKey<ExtendedImageEditorState>();
  bool _confirmed = false;

  void _confirm() {
    if (_confirmed) return;
    final rect = _editorKey.currentState?.getCropRect();
    if (rect == null || rect.isEmpty || !rect.isFinite) return;
    _confirmed = true;
    if (widget.useHapticFeedback) HapticFeedback.heavyImpact().ignore();
    widget.onChanged?.call(rect);
    if (mounted) Navigator.of(context).pop<Rect>(rect);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UILocalizations.of(context);
    final theme = Theme.of(context);
    final avatar = widget.imageEditorType == UIImageEditorType.avatar;
    return UIAnnotateRegion(
      child: Scaffold(
        appBar: CupertinoNavigationBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          automaticBackgroundVisibility: false,
          enableBackgroundFilterBlur: false,
          border: const Border(),
          automaticallyImplyLeading: false,
          middle: Text(l10n.screenEditPhotoTitle),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: EdgeInsets.all(theme.uiTheme.size.offset.extraSmall),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                onPressed: () {
                  if (widget.useHapticFeedback) HapticFeedback.heavyImpact().ignore();
                  Navigator.of(context).pop<void>();
                },
                child: Text(l10n.cancelButton),
              ),
              CupertinoButton(onPressed: _confirm, child: Text(l10n.doneButton)),
            ],
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => UIImageEditor(
              file: widget.file,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              editorKey: _editorKey,
              initEditorConfigHandler: (_) => EditorConfig(
                maxScale: 8,
                cropAspectRatio: avatar ? CropAspectRatios.ratio1_1 : widget.aspectRatio,
                cornerColor: theme.uiTheme.color.text,
                cropRectPadding: EdgeInsets.all(theme.uiTheme.size.offset.regular),
                cropLayerPainter: avatar ? const _CircleCropLayerPainter() : const EditorCropLayerPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleCropLayerPainter extends EditorCropLayerPainter {
  const _CircleCropLayerPainter();

  @override
  void paintCorners(Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {}

  @override
  void paintMask(Canvas canvas, Rect rect, ExtendedImageCropLayerPainter painter) {
    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addOval(painter.cropRect);
    canvas.drawPath(mask, Paint()..color = painter.maskColor);
  }

  @override
  void paintLines(Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    if (!painter.pointerDown) return;
    canvas
      ..save()
      ..clipPath(Path()..addOval(painter.cropRect));
    super.paintLines(canvas, size, painter);
    canvas.restore();
  }
}
