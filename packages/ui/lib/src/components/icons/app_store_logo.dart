// ignore_for_file: library_private_types_in_public_api

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// {@template get_app_store_logo}
/// GetAppStoreLogo widget.
/// {@endtemplate}
class GetAppStoreLogo extends StatelessWidget implements PreferredSizeWidget {
  /// {@macro get_app_store_logo}
  const GetAppStoreLogo({
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
  /// For example: 'Download on the'
  final String? label;

  /// The tooltip of the button.
  /// For example: 'Download on the App Store'
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
                          child: Center(child: AppStoreLogo()),
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
                              const SizedBox(height: 32.0, child: AppStoreLogo()),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      label ?? 'Download on the',
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
                                      'App Store',
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

/// {@template app_store_logo}
/// AppStoreLogo widget.
/// {@endtemplate}
class AppStoreLogo extends LeafRenderObjectWidget implements PreferredSizeWidget {
  /// {@macro app_store_logo}
  const AppStoreLogo({super.key});

  /// The size of the logo.
  static const Size size = Size(27.8, 33.2);

  @override
  Size get preferredSize => size;

  @override
  RenderObject createRenderObject(BuildContext context) => _AppStoreLogoRenderObject().._targetSize = size;

  @override
  void updateRenderObject(BuildContext context, covariant _AppStoreLogoRenderObject renderObject) {
    if (renderObject case _AppStoreLogoRenderObject object when object._targetSize != size) {
      renderObject
        .._targetSize = size
        ..markNeedsLayout();
    }
  }
}

class _AppStoreLogoRenderObject extends RenderBox {
  _AppStoreLogoRenderObject();

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
    _scale = math.min(size.width / AppStoreLogo.size.width, size.height / AppStoreLogo.size.height);
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
        offset.dx + (size.width - AppStoreLogo.size.width * scale) / 2,
        offset.dy + (size.height - AppStoreLogo.size.height * scale) / 2,
      );
    } else if (scale == 1.0) {
      // Move the logo to the center of the box.
      canvas.translate(offset.dx, offset.dy);
    } else {
      // Move the center of the logo to the center of the box.
      canvas.translate(
        offset.dx + (size.width - AppStoreLogo.size.width * scale) / 2,
        offset.dy + (size.height - AppStoreLogo.size.height * scale) / 2,
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
    const size = AppStoreLogo.size;

    final path_0 = Path()
      ..moveTo(size.width * 0.8354143, size.height * 0.5211500)
      ..cubicTo(
        size.width * 0.8340286,
        size.height * 0.3979176,
        size.width * 0.9617821,
        size.height * 0.3379647,
        size.width * 0.9676214,
        size.height * 0.3351735,
      )
      ..cubicTo(
        size.width * 0.8952714,
        size.height * 0.2509421,
        size.width * 0.7831286,
        size.height * 0.2394332,
        size.width * 0.7437179,
        size.height * 0.2385156,
      )
      ..cubicTo(
        size.width * 0.6495321,
        size.height * 0.2306009,
        size.width * 0.5581714,
        size.height * 0.2835185,
        size.width * 0.5101893,
        size.height * 0.2835185,
      )
      ..cubicTo(
        size.width * 0.4612536,
        size.height * 0.2835185,
        size.width * 0.3873679,
        size.height * 0.2392803,
        size.width * 0.3077386,
        size.height * 0.2405803,
      )
      ..cubicTo(
        size.width * 0.2052679,
        size.height * 0.2418421,
        size.width * 0.1094050,
        size.height * 0.2892156,
        size.width * 0.05682857,
        size.height * 0.3627794,
      )
      ..cubicTo(
        size.width * -0.05167571,
        size.height * 0.5127765,
        size.width * 0.02924771,
        size.height * 0.7332029,
        size.width * 0.1332029,
        size.height * 0.8544471,
      )
      ..cubicTo(
        size.width * 0.1852046,
        size.height * 0.9138265,
        size.width * 0.2459689,
        size.height * 0.9801265,
        size.width * 0.3255036,
        size.height * 0.9777941,
      )
      ..cubicTo(
        size.width * 0.4033143,
        size.height * 0.9752324,
        size.width * 0.4323786,
        size.height * 0.9381824,
        size.width * 0.5262786,
        size.height * 0.9381824,
      )
      ..cubicTo(
        size.width * 0.6193179,
        size.height * 0.9381824,
        size.width * 0.6466107,
        size.height * 0.9777941,
        size.width * 0.7277250,
        size.height * 0.9763029,
      )
      ..cubicTo(
        size.width * 0.8112357,
        size.height * 0.9752324,
        size.width * 0.8638107,
        size.height * 0.9166559,
        size.width * 0.9139929,
        size.height * 0.8567412,
      )
      ..cubicTo(
        size.width * 0.9740857,
        size.height * 0.7886824,
        size.width * 0.9982214,
        size.height * 0.7216559,
        size.width * 0.9991786,
        size.height * 0.7182147,
      )
      ..cubicTo(
        size.width * 0.9972143,
        size.height * 0.7176794,
        size.width * 0.8369964,
        size.height * 0.6688529,
        size.width * 0.8354143,
        size.height * 0.5211500,
      )
      ..close();

    final paint0Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawPath(path_0, paint0Fill);

    final path_1 = Path()
      ..moveTo(size.width * 0.6821893, size.height * 0.1587568)
      ..cubicTo(
        size.width * 0.7240393,
        size.height * 0.1169656,
        size.width * 0.7526714,
        size.height * 0.06010971,
        size.width * 0.7447250,
        size.height * 0.002412682,
      )
      ..cubicTo(
        size.width * 0.6841500,
        size.height * 0.004553853,
        size.width * 0.6084000,
        size.height * 0.03586853,
        size.width * 0.5647786,
        size.height * 0.07674206,
      )
      ..cubicTo(
        size.width * 0.5261821,
        size.height * 0.1127597,
        size.width * 0.4917071,
        size.height * 0.1717950,
        size.width * 0.5006143,
        size.height * 0.2273126,
      )
      ..cubicTo(
        size.width * 0.5686571,
        size.height * 0.2313656,
        size.width * 0.6385179,
        size.height * 0.1998979,
        size.width * 0.6821893,
        size.height * 0.1587568,
      )
      ..close();

    final paint1Fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawPath(path_1, paint1Fill);

    return recorder.endRecording();
  }();
}
