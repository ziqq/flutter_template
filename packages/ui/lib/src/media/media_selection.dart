/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 13 August 2026
 */

import 'dart:ui' show Rect;

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:flutter/foundation.dart' show immutable;

/// Carries a picker-selected image and its optional crop back to the caller.
///
/// The [crop] coordinates are expressed in source-image pixels. A `null` crop
/// means the complete image should be used.
@immutable
final class UIMediaSelection {
  /// Creates a selected local image payload.
  const UIMediaSelection({required this.file, this.crop});

  /// Picker-provided file that remains usable on native platforms and Web.
  final XFile file;

  /// The crop rectangle chosen by the user, in source-image pixels.
  final Rect? crop;

  @override
  int get hashCode => Object.hash(file.path, file.name, crop);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UIMediaSelection && file.path == other.file.path && file.name == other.file.name && crop == other.crop);
}
