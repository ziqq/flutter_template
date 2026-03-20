import 'dart:math' as math;
import 'dart:ui' as ui hide Size;

import 'package:flutter/material.dart';

/// Avatar icon widget.
class UIIcon$Avatar extends LeafRenderObjectWidget implements PreferredSizeWidget {
  const UIIcon$Avatar({this.size = 24, this.brightness, super.key});

  final double size;
  final Brightness? brightness;

  @override
  Size get preferredSize => Size.square(size);

  @override
  RenderObject createRenderObject(BuildContext context) {
    final isDark = (brightness ?? Theme.of(context).brightness) == Brightness.dark;
    return _UIIcon$AvatarRenderObject()
      .._targetSize = Size.square(size)
      .._isDark = isDark;
  }

  @override
  void updateRenderObject(BuildContext context, RenderBox renderObject) {
    if (renderObject is _UIIcon$AvatarRenderObject) {
      final isDark = (brightness ?? Theme.of(context).brightness) == Brightness.dark;
      renderObject
        .._targetSize = Size.square(size)
        .._isDark = isDark;
    }
  }
}

class _UIIcon$AvatarRenderObject extends RenderBox {
  static const double _designMax = 91.0; // original design square side reference

  Size _targetSize = Size.zero;
  bool _isDark = false;
  double _scale = .0;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(_targetSize);

  @override
  void performLayout() {
    final size = super.size = computeDryLayout(constraints);
    _scale = math.min(size.width / 24.0, size.height / 24.0);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_scale < .01) return;
    final canvas = context.canvas..save();
    final sideScaled = 24.0 * _scale;
    canvas
      ..translate(offset.dx + (size.width - sideScaled) / 2, offset.dy + (size.height - sideScaled) / 2)
      ..scale(_scale)
      ..scale(24.0 / _designMax); // bring 91x90 design into 24 box

    final bg = _isDark ? const Color(0xff3D3C3E) : const Color(0xffDEE3E7);
    final fg = _isDark ? const Color(0xff6F6E72) : const Color(0xffFFFFFF);

    final picture = _buildPicture(bg, fg);
    canvas
      ..drawPicture(picture)
      ..restore();
    picture.dispose();
  }

  static ui.Picture _buildPicture(Color bg, Color fg) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = bg;
    canvas.drawPath(path_0, paint);
    paint.color = fg;
    canvas.drawPath(path_1, paint);
    return recorder.endRecording();
  }

  static final Path path_0 = Path()
    ..fillType = PathFillType.evenOdd
    ..moveTo(91, 0)
    ..lineTo(0, 0)
    ..lineTo(0, 90)
    ..lineTo(91, 90)
    ..close();

  static final Path path_1 = Path()
    ..fillType = PathFillType.evenOdd
    ..moveTo(91.1, 90.5)
    ..lineTo(0, 90.5)
    ..cubicTo(-0.9, 62.4, 22.1, 63.7, 33.6, 56.9)
    ..cubicTo(36.8, 55, 37.1, 49.9, 35.2, 47.2)
    ..cubicTo(28, 36.9, 27.2, 30.9, 28.1, 22)
    ..cubicTo(29.7, 7.5, 44, 6.8, 44, 6.8)
    ..lineTo(47, 6.8)
    ..cubicTo(47, 6.8, 61.4, 7.5, 62.9, 22)
    ..cubicTo(63.8, 30.8, 63.1, 36.9, 55.8, 47.2)
    ..cubicTo(53.9, 49.9, 54.3, 55.1, 57.4, 56.9)
    ..cubicTo(69, 63.7, 92, 62.4, 91.1, 90.5)
    ..close();
}
