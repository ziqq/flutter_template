// ignore_for_file: library_private_types_in_public_api

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// {@template get_google_play_logo}
/// GetGooglePlayLogo widget.
/// {@endtemplate}
class GetGooglePlayLogo extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro get_google_play_logo}
  const GetGooglePlayLogo({
    this.label,
    this.tooltip,
    this.onTap,
    super.key, // ignore: unused_element
  });

  /// The size of the logo.
  static const Size size = Size(180, 52);
  static final double targetAspectRatio = size.width / size.height;

  @override
  Size get preferredSize => size;

  /// Called when the user taps this button.
  final VoidCallback? onTap;

  /// The label of the button.
  /// For example: 'GET IT ON'
  final String? label;

  /// The tooltip of the button.
  /// For example: 'Download on Google Play'
  final String? tooltip;

  static Widget _wrapWithTooltip({required Widget child, String? tooltip}) {
    if (tooltip case String message when message.isNotEmpty) return Tooltip(message: message, child: child);
    return child;
  }

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox.fromSize(
      size: size,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.smallest.shortestSide < 24) return const SizedBox.shrink();
          final boxAspectRatio = constraints.maxWidth / constraints.maxHeight;
          // If aspect ratio is too low, display only the logo.
          // otherwise, display the full button with text.
          if (boxAspectRatio < targetAspectRatio * 0.7) {
            return Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Material(
                  color: Colors.transparent,
                  type: MaterialType.button,
                  borderRadius: BorderRadius.circular(12.0),
                  elevation: 4.0,
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(12.0),
                      child: _wrapWithTooltip(
                        tooltip: tooltip,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: GooglePlayLogo()),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: SizedBox.fromSize(
                size: size,
                child: Material(
                  color: Colors.transparent,
                  type: MaterialType.button,
                  borderRadius: BorderRadius.circular(12.0),
                  elevation: 4.0,
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(12.0),
                      child: _wrapWithTooltip(
                        tooltip: tooltip,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(height: 32.0, child: GooglePlayLogo()),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      label ?? 'GET IT ON',
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.0,
                                        letterSpacing: 1.1,
                                        fontWeight: FontWeight.w600,
                                        height: 1.0,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    const Text(
                                      'Google Play',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w700,
                                        height: 1.0,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
        },
      ),
    ),
  );
}

/// {@template google_play_logo}
/// GooglePlayLogo widget.
/// {@endtemplate}
class GooglePlayLogo extends LeafRenderObjectWidget implements PreferredSizeWidget {
  /// {@macro google_play_logo}
  const GooglePlayLogo({super.key});

  /// The size of the logo.
  static const Size size = Size(31.0, 33.4);

  @override
  Size get preferredSize => size;

  @override
  RenderObject createRenderObject(BuildContext context) => _GooglePlayLogoRenderObject().._targetSize = size;

  @override
  void updateRenderObject(BuildContext context, covariant _GooglePlayLogoRenderObject renderObject) {
    if (renderObject case _GooglePlayLogoRenderObject object when object._targetSize != size) {
      renderObject
        .._targetSize = size
        ..markNeedsLayout();
    }
  }
}

class _GooglePlayLogoRenderObject extends RenderBox {
  _GooglePlayLogoRenderObject();

  Size _targetSize = Size.zero;
  double _scale = .0;

  @override
  bool get isRepaintBoundary => false;

  @override
  bool get alwaysNeedsCompositing => false;

  @override
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(_targetSize);

  @override
  void performLayout() {
    final size = super.size = computeDryLayout(constraints);
    _scale = math.min(size.width / GooglePlayLogo.size.width, size.height / GooglePlayLogo.size.height);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    final scale = _scale;
    final canvas = context.canvas..save();
    if (scale < .01) {
      // No need to paint if the scale is too small.
      return;
    } else if (scale < 1.0) {
      // Move the logo to the center of the box.
      canvas.translate(
        offset.dx + (size.width - GooglePlayLogo.size.width * scale) / 2,
        offset.dy + (size.height - GooglePlayLogo.size.height * scale) / 2,
      );
    } else if (scale == 1.0) {
      // Move the logo to the center of the box.
      canvas.translate(offset.dx, offset.dy);
    } else {
      // Move the center of the logo to the center of the box.
      canvas.translate(
        offset.dx + (size.width - GooglePlayLogo.size.width * scale) / 2,
        offset.dy + (size.height - GooglePlayLogo.size.height * scale) / 2,
      );
    }
    canvas
      //  ..clipRect(Offset.zero & size)
      ..scale(scale, scale)
      ..drawPicture(_$logoPicture)
      ..restore();
  }

  static final ui.Picture _$logoPicture = () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = GooglePlayLogo.size;

    final path_0 = Path()
      ..moveTo(size.width * 0.03102691, size.height * 0.02351362)
      ..cubicTo(
        size.width * 0.01871931,
        size.height * 0.03527088,
        size.width * 0.01159669,
        size.height * 0.05357618,
        size.width * 0.01159669,
        size.height * 0.07728206,
      )
      ..lineTo(size.width * 0.01159669, size.height * 0.9228559)
      ..cubicTo(
        size.width * 0.01159669,
        size.height * 0.9465618,
        size.width * 0.01871931,
        size.height * 0.9648676,
        size.width * 0.03102691,
        size.height * 0.9766235,
      )
      ..lineTo(size.width * 0.03406469, size.height * 0.9792059)
      ..lineTo(size.width * 0.5532875, size.height * 0.5055647)
      ..lineTo(size.width * 0.5532875, size.height * 0.4943824)
      ..lineTo(size.width * 0.03406469, size.height * 0.02074165)
      ..lineTo(size.width * 0.03102691, size.height * 0.02351362)
      ..close();

    final paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5071875, size.height * 0.9316618),
        Offset(size.width * -17.42741, size.height * 0.2701871),
        [
          const Color(0xff00A0FF),
          const Color(0xff00A1FF),
          const Color(0xff00BEFF),
          const Color(0xff00D2FF),
          const Color(0xff00DFFF),
          const Color(0xff00E3FF),
        ],
        [0, 0.0066, 0.2601, 0.5122, 0.7604, 1],
      );
    canvas.drawPath(path_0, paint0Fill);

    final path_1 = Path()
      ..moveTo(size.width * 0.7261062, size.height * 0.6635441)
      ..lineTo(size.width * 0.5532219, size.height * 0.5055853)
      ..lineTo(size.width * 0.5532219, size.height * 0.4944029)
      ..lineTo(size.width * 0.7263156, size.height * 0.3364412)
      ..lineTo(size.width * 0.7301906, size.height * 0.3384971)
      ..lineTo(size.width * 0.9351750, size.height * 0.4449353)
      ..cubicTo(
        size.width * 0.9936781,
        size.height * 0.4751412,
        size.width * 0.9936781,
        size.height * 0.5248471,
        size.width * 0.9351750,
        size.height * 0.5552441,
      )
      ..lineTo(size.width * 0.7301906, size.height * 0.6614912)
      ..lineTo(size.width * 0.7261062, size.height * 0.6635441)
      ..close();

    final paint1Fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(size.width * 1.011353, size.height * 0.4999412),
        Offset(size.width * -0.2451384, size.height * 0.4999412),
        [const Color(0xffFFE000), const Color(0xffFFBD00), const Color(0xffFFA500), const Color(0xffFF9C00)],
        [0, 0.4087, 0.7754, 1],
      );
    canvas.drawPath(path_1, paint1Fill);

    final path_2 = Path()
      ..moveTo(size.width * 0.7302344, size.height * 0.6614765)
      ..lineTo(size.width * 0.5532656, size.height * 0.4999824)
      ..lineTo(size.width * 0.03100587, size.height * 0.9766324)
      ..cubicTo(
        size.width * 0.05043625,
        size.height * 0.9952706,
        size.width * 0.08212156,
        size.height * 0.9975176,
        size.width * 0.1181541,
        size.height * 0.9788794,
      )
      ..lineTo(size.width * 0.7302344, size.height * 0.6614765)
      ..close();

    final paint2Fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.6340031, size.height * 0.4121882),
        Offset(size.width * -29.01119, size.height * -48.48235),
        [const Color(0xffFF3A44), const Color(0xffC31162)],
        [0, 1],
      );
    canvas.drawPath(path_2, paint2Fill);

    final path_3 = Path()
      ..moveTo(size.width * 0.7302344, size.height * 0.3385029)
      ..lineTo(size.width * 0.1181541, size.height * 0.02110312)
      ..cubicTo(
        size.width * 0.08212156,
        size.height * 0.002654603,
        size.width * 0.05043625,
        size.height * 0.004900853,
        size.width * 0.03100587,
        size.height * 0.02354056,
      )
      ..lineTo(size.width * 0.5532656, size.height * 0.5000000)
      ..lineTo(size.width * 0.7302344, size.height * 0.3385029)
      ..close();

    final paint3Fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(size.width * -10.04578, size.height * 1.257968),
        Offset(size.width * 0.3122012, size.height * 0.8574147),
        [
          const Color(0xff32A071),
          const Color(0xff2DA771),
          const Color(0xff15CF74),
          const Color(0xff06E775),
          const Color(0xff00F076),
        ],
        [0, 0.0685, 0.4762, 0.8009, 1],
      );
    canvas.drawPath(path_3, paint3Fill);

    return recorder.endRecording();
  }();
}
