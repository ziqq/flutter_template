/*
 * Date: 04 June 2026
 */

/// This is the main library file for the UI package.
/// It exports all the necessary components and themes for the UI layer of the application.
library;

export 'package:flutter/material.dart';

export 'src/components/_components.dart' hide OptimizedClip, RenderPaddingExtended;
export 'src/localization/localization.dart';
export 'src/theme/theme.dart';
export 'src/ui.dart';
