import 'package:flutter/material.dart' show IconData;
import 'package:flutter/widgets.dart' show staticIconProvider;

export 'app_store_logo.dart';
export 'avatar_icon.dart';
export 'google_play_logo.dart';
export 'image_icon.dart';

/// {@template ui_icons}
/// A static icon data provider for the app icon font.
/// {@endtemplate}
@staticIconProvider
abstract final class UIIcons {
  static const String fontFamily = 'icomoon';

  /// Example icon
  /* static const IconData example = IconData(0xe90b, fontFamily: fontFamily, fontPackage: 'ui'); */

  /// A list of all available icons.
  static const Map<String, IconData> values = {/* 'example:' example */};
}
