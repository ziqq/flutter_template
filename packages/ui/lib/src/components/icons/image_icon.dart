import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Photo stub icon widget.
class UIIcon$Photo$Stub extends LeafRenderObjectWidget implements PreferredSizeWidget {
  const UIIcon$Photo$Stub({this.size = 24, super.key});

  final double size;

  @override
  Size get preferredSize => Size.square(size);

  @override
  RenderObject createRenderObject(BuildContext context) => _UIIcon$Photo$StubRenderObject()
    .._targetSize = Size.square(size)
    .._isDark = Theme.of(context).brightness == Brightness.dark;

  @override
  void updateRenderObject(BuildContext context, RenderBox renderObject) {
    if (renderObject is _UIIcon$Photo$StubRenderObject) {
      renderObject
        .._targetSize = Size.square(size)
        .._isDark = Theme.of(context).brightness == Brightness.dark;
    }
  }
}

class _UIIcon$Photo$StubRenderObject extends RenderBox {
  Size _targetSize = Size.zero;
  Color? _foregroundOverride;
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
      ..scale(_scale, _scale);
    final pic = _buildPicture(_isDark, _foregroundOverride);
    canvas
      ..drawPicture(pic)
      ..restore();
    pic.dispose();
  }

  static ui.Picture _buildPicture(bool isDark, Color? foregroundOverride) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    final bg = isDark ? const Color(0xff3A3A3C) : const Color(0xfff7f5fd);
    final fg = foregroundOverride ?? (isDark ? const Color(0xff6F6F73) : const Color(0xFFdee3e7));
    canvas
      ..drawPath(path_0, paint..color = bg)
      ..drawPath(path_1, paint..color = fg);
    return recorder.endRecording();
  }

  static final Path path_0 = Path()
    ..moveTo(24, 0)
    ..lineTo(0, 0)
    ..lineTo(0, 24)
    ..lineTo(24, 24)
    ..close();

  static final Path path_1 = Path()
    ..moveTo(13.83, 8.51)
    ..lineTo(10.15, 8.51)
    ..cubicTo(9.71, 8.51, 9.3, 8.68, 8.99, 8.99)
    ..cubicTo(8.68, 9.3, 8.51, 9.71, 8.51, 10.15)
    ..lineTo(8.51, 13.83)
    ..cubicTo(8.51, 14.27, 8.68, 14.68, 8.99, 14.99)
    ..cubicTo(9.3, 15.3, 9.71, 15.47, 10.15, 15.47)
    ..lineTo(13.83, 15.47)
    ..cubicTo(14.27, 15.47, 14.68, 15.3, 14.99, 14.99)
    ..cubicTo(15.3, 14.68, 15.47, 14.27, 15.47, 13.83)
    ..lineTo(15.47, 10.15)
    ..cubicTo(15.47, 9.71, 15.3, 9.3, 14.99, 8.99)
    ..cubicTo(14.68, 8.68, 14.27, 8.51, 13.83, 8.51)
    ..close()
    ..moveTo(10.53, 9.61)
    ..cubicTo(10.97, 9.61, 11.33, 9.97, 11.33, 10.42)
    ..cubicTo(11.33, 10.87, 10.97, 11.23, 10.53, 11.23)
    ..cubicTo(10.09, 11.23, 9.73, 10.87, 9.73, 10.42)
    ..cubicTo(9.73, 9.97, 10.09, 9.61, 10.53, 9.61)
    ..close()
    ..moveTo(14.39, 14.11)
    ..cubicTo(13.9, 14.85, 12.63, 14.71, 11.81, 14.71)
    ..cubicTo(10.99, 14.71, 9.6, 14.79, 9.39, 14.16)
    ..cubicTo(9.26, 13.41, 9.98, 12.86, 10.33, 12.86)
    ..cubicTo(10.85, 12.86, 11.41, 14.35, 12.14, 13.49)
    ..cubicTo(12.88, 12.64, 12.92, 11.8, 13.57, 11.8)
    ..cubicTo(14.38, 11.8, 14.97, 13.23, 14.38, 14.11)
    ..close();
}
