// ignore_for_file: sort_constructors_first

/*
 * Date: 04 June 2026
 */

import 'package:flutter/cupertino.dart' as cupertino_ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material_ui;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:ui/ui.dart';

// Standard iOS 10 tab bar height.
const double kTabBarHeight = 62;

/// Default snackbar duration.
const _kDefaultSnackBarDuration = Duration(milliseconds: 2000);

/// Default snackbar border radius.
const _kDefaultSnackBarBorderRadius = BorderRadius.all(Radius.circular(15));

/// {@template ui_snackbar_type}
/// SnackBar type aspect
/// {@endtemplate}
enum UISnackBarType {
  /// Success aspect
  success,

  /// Error aspect
  error,
}

/// {@template ui}
/// UI is a class that contains helper methods for showing dialogs, snackbars, and other UI elements.
/// {@endtemplate}
final class UI {
  static final UI _instance = UI._internal();
  static UI get instance => _instance;

  /// {@macro ui}
  UI._internal();

  /// Displays a Cupertino-style modal popup.
  static Future<T?> showCupertinoModal<T>({
    required BuildContext context,
    String? cancelButtonText,
    Color? cancelButtonColor,
    Widget? title,
    Widget? message,
    List<Widget>? actions,
    bool useRootNavigator = true,
  }) async {
    final theme = Theme.of(context);
    final l10n = UILocalizations.of(context);
    return await showCupertinoModalPopup<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierColor: CupertinoDynamicColor.resolve(kCupertinoModalBarrierColor, context),
      builder: (context) => CupertinoActionSheet(
        title: title,
        message: message,
        actions: actions,
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context, rootNavigator: useRootNavigator).pop<void>(),
          child: Text(
            cancelButtonText ?? l10n.cancelButton,
            style: TextStyle(color: cancelButtonColor ?? theme.uiTheme.color.accent),
          ),
        ),
      ),
    );
  }

  /// Show an adaptive alert dialog.
  static Future<T?> showAdaptiveAlertDialog<T>({
    required BuildContext context,
    Widget? icon,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    bool scrollable = false,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    bool barrierDismissible = true,
  }) async {
    final theme = Theme.of(context);
    return await showAdaptiveDialog<T>(
      context: context,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog.adaptive(
        icon: icon,
        title: title,
        content: content,
        actions: actions,
        scrollable: scrollable,
        iconPadding: .all(theme.uiTheme.size.offset.medium),
        titlePadding: .only(left: theme.uiTheme.size.offset.medium, right: theme.uiTheme.size.offset.medium),
        actionsPadding: .only(
          left: theme.uiTheme.size.offset.medium,
          right: theme.uiTheme.size.offset.medium,
          bottom: theme.uiTheme.size.offset.regular,
          top: content == null ? theme.uiTheme.size.offset.regular : 0,
        ),
        contentPadding: .only(
          left: theme.uiTheme.size.offset.medium,
          right: theme.uiTheme.size.offset.medium,
          bottom: theme.uiTheme.size.offset.regular,
          top: theme.uiTheme.size.offset.extraExtraSmall,
        ),
        contentTextStyle: theme.textTheme.labelMedium,
      ),
    );
  }

  /// Show a modal bottom sheet.
  ///
  /// This method displays a modal bottom sheet with the specified
  /// [builder] and other optional parameters. If [useHapticFeedback] is true,
  /// it triggers medium impact haptic feedback.
  ///
  /// Parameters:
  /// - [context]: The build context to show the modal bottom sheet.
  /// - [builder]: A function that returns the widget to display in the modal bottom sheet.
  /// - [shape]: The shape of the modal bottom sheet.
  /// - [barrierColor]: The color of the barrier.
  /// - [backgroundColor]: The background color of the modal bottom sheet.
  /// - [enableDrag]: Whether the modal bottom sheet can be dragged. Defaults to `true`.
  /// - [isDismissible]: Whether the modal bottom sheet is dismissible. Defaults to `true`.
  /// - [isScrollControlled]: Whether the modal bottom sheet is scroll controlled. Defaults to `false`.
  /// - [useSafeArea]: Whether to use safe area. Defaults to `false`.
  /// - [useRootNavigator]: Whether to use the root navigator. Defaults to `false`.
  /// - [useHapticFeedback]: Whether to use haptic feedback. Defaults to `false`.
  static Future<T?> showModalBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    ShapeBorder? shape,
    Color? barrierColor,
    Color? backgroundColor,
    bool enableDrag = true,
    bool isDismissible = true,
    bool isScrollControlled = false,
    bool useSafeArea = false,
    bool useRootNavigator = false,
    bool useHapticFeedback = true,
  }) async {
    if (useHapticFeedback) HapticFeedback.heavyImpact().ignore();
    return await material_ui.showModalBottomSheet<T>(
      context: context,
      builder: builder,
      shape: shape,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor ?? CupertinoDynamicColor.resolve(kCupertinoModalBarrierColor, context),
    );
  }

  /// Show adaptive modal bottom sheet
  /// This method call [showModalBottomSheet] from [materialUI]
  /// and [showCupertinoSheet] from [cupertino]
  static Future<T?> showAdaptiveModalBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    ShapeBorder? shape,
    Color? barrierColor,
    Color? backgroundColor,
    bool enableDrag = true,
    bool isDismissible = true,
    bool isScrollControlled = false,
    bool useSafeArea = false,
    bool useRootNavigator = true,
    bool useHapticFeedback = false,
    bool useNestedNavigation = false,
  }) async {
    if (useHapticFeedback) HapticFeedback.heavyImpact().ignore();
    // TODO(ziqq): Can u uncomment this line when u will fix platform from theme.
    // Anton Ustinoff <a.a.ustinoff@gmail.com>, 14 August 2025
    switch ( /* Theme.of(context).platform */ defaultTargetPlatform) {
      case .android:
      case .fuchsia:
      case .windows:
      case .linux:
        return await showModalBottomSheet<T?>(
          context: context,
          builder: builder,
          enableDrag: enableDrag,
          useSafeArea: useSafeArea,
          isDismissible: isDismissible,
          useRootNavigator: useRootNavigator,
          isScrollControlled: isScrollControlled,
          barrierColor: barrierColor ?? CupertinoDynamicColor.resolve(kCupertinoModalBarrierColor, context),
          backgroundColor: backgroundColor,
          shape: shape,
        );
      case .macOS:
      case .iOS:
        return await showCupertinoSheet<T?>(
          context: context,
          builder: builder,
          enableDrag: enableDrag,
          useNestedNavigation: useNestedNavigation,
        );
    }
  }

  /// Show a cupertino sheet.
  static Future<T?> showCupertinoSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool enableDrag = true,
    bool useHapticFeedback = true,
    bool useNestedNavigation = false,
  }) async {
    if (useHapticFeedback) HapticFeedback.heavyImpact().ignore();
    return await cupertino_ui.showCupertinoSheet<T>(
      context: context,
      builder: builder,
      enableDrag: enableDrag,
      useNestedNavigation: useNestedNavigation,
    );
  }

  /// Show the snackbar.
  ///
  /// This method displays a snackbar with the specified
  /// [message] and [type].
  ///
  /// If [useHapticFeedback] is true, it triggers
  /// haptic feedback based on the [type] of the snackbar.
  ///
  /// Parameters:
  /// - [context]: The build context to show the snackbar.
  /// - [message]: The message to display in the snackbar.
  /// - [type]: The type of the snackbar, either [UISnackBarType.error] or
  ///   [UISnackBarType.success]. Defaults to [UISnackBarType.error].
  /// Additional parameters:
  /// - [useHapticFeedback]: Whether to use haptic feedback. Defaults to false.
  /// - [useBottomOffset]: Whether to apply a bottom offset to the snackbar.
  /// - [positionOffset]: The position offset for the snackbar. Defaults to 0.0.
  static Future<void> showSnackBar({
    required BuildContext context,
    UISnackBarType type = UISnackBarType.error,
    bool useHapticFeedback = false,
    bool useBottomOffset = false,
    double positionOffset = .0,
    String? message,
  }) async {
    if (useHapticFeedback) {
      if (type == UISnackBarType.success) HapticFeedback.heavyImpact().ignore();
      if (type == UISnackBarType.error) HapticFeedback.vibrate().ignore();
    }
    await _$showDefaultSnackbar(
      context: context,
      message: message,
      type: type,
      bottomOffset: useBottomOffset ? kTabBarHeight : positionOffset,
    );
  }

  /// Show default snackbar use [ScaffoldMessenger]
  // ignore: unused_element
  static Future<void> _$showDefaultSnackbar({
    required BuildContext context,
    UISnackBarType type = UISnackBarType.error,
    double bottomOffset = .0,
    String? message,
    Widget? content,
    Widget? icon,
  }) async {
    assert(message != null || content != null, 'Message or content must be provided');
    final theme = Theme.of(context);
    final snackBar = SnackBar(
      content:
          content ??
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: theme.uiTheme.size.offset.extraSmall,
            children: <Widget>[
              icon ?? _UISnackBarIcon(type: type),
              Flexible(
                child: Text(
                  message ?? 'No message yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.2,
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
      elevation: 0,
      behavior: .floating,
      padding: const .all(10),
      duration: _kDefaultSnackBarDuration,
      backgroundColor: theme.uiTheme.color.snackbarBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: _kDefaultSnackBarBorderRadius),
      margin: .only(left: 16, right: 16, bottom: theme.uiTheme.padding + bottomOffset),
    );
    material_ui.ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Show image select dialog
  /* static Future<void> showImageSelect({
    BuildContext? rootContext,
    BuildContext? context,
    void Function(Photo)? onChanged,
    double aspectRatio = CropAspectRatios.ratio4_3,
  }) async {
    final effectiveContext = rootContext ?? context;
    if (effectiveContext == null) return;
    final navigator = Navigator.of(effectiveContext, rootNavigator: true);
    final localization = UILocalizations.of(effectiveContext);
    final theme = Theme.of(effectiveContext);
    await showCupertinoModal<void>(
      context: effectiveContext,
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            navigator.pop(ImageSource.camera);
            pickImage(
              source: ImageSource.camera,
              context: context,
              onChanged: onChanged,
              rootContext: rootContext,
              aspectRatio: aspectRatio,
            );
          },
          child: Text(localization.actionPhotoMake, style: TextStyle(color: theme.uiTheme.color.accent)),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            navigator.pop(ImageSource.gallery);
            pickImage(
              source: ImageSource.gallery,
              context: context,
              onChanged: onChanged,
              rootContext: rootContext,
              aspectRatio: aspectRatio,
            );
          },
          child: Text(localization.actionPhotoSelectFromGallery, style: TextStyle(color: theme.uiTheme.color.accent)),
        ),
      ],
    );
  } */

  /// Picks an image from [source], allows cropping,
  /// and returns the result via [onChanged].
  ///
  /// [source] specifies the image source (e.g., camera or gallery).
  ///
  /// [rootContext] or [context] provides a context for the picker and editor.
  ///
  /// [onChanged] is called with the resulting [Photo]
  /// if an image is picked and cropped.
  ///
  /// [aspectRatio] specifies the cropping tool's aspect ratio
  /// (default is [CropAspectRatios.ratio4_3]).
  ///
  /// Shows a permission dialog if access to the photo library is denied.
  ///
  /// Example:
  /// ```dart
  /// await pickImage(
  ///   source: ImageSource.gallery,
  ///   context: context,
  ///   onChanged: (photo) { /* Handle the picked and cropped photo */},
  /// );
  /// ```
  /* static Future<void> pickImage({
    required ImageSource source,
    BuildContext? rootContext,
    BuildContext? context,
    void Function(Photo)? onChanged,
    double aspectRatio = CropAspectRatios.ratio4_3,
  }) async {
    assert(context != null || rootContext != null, 'context or rootContext must be not null');
    final effectiveContext = rootContext ?? context;
    if (effectiveContext == null) return;

    final picker = ImagePicker();
    XFile? image;

    try {
      image = await picker.pickImage(source: source, maxWidth: 1500, maxHeight: 1500, imageQuality: 100);

      if (image == null) return;
      if (!effectiveContext.mounted) return;

      final file = File(image.path);
      Crop? result;

      result = await UIImageEditorScreen.push(context: effectiveContext, aspectRatio: aspectRatio, file: file);
      if (result == null) return;

      final photo = Photo(image: image.path, crop: result, file: file);
      onChanged?.call(photo);
    } on PlatformException catch (e) {
      if (e.code == 'photo_access_denied') {
        if (!effectiveContext.mounted) return;
        image = await showPermissionMediaLibraryDialog(
          context: effectiveContext,
          source: source,
          maxWidth: 1500,
          maxHeight: 1500,
          imageQuality: 100,
        );
      }
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  } */
}

/// Snackbar icon widget.
class _UISnackBarIcon extends StatelessWidget {
  /// {@macro ui_snackbar_icon}
  const _UISnackBarIcon({
    required this.type,
    super.key, // ignore: unused_element_parameter
  });

  final UISnackBarType type;

  @override
  Widget build(BuildContext context) => Icon(
    switch (type) {
      UISnackBarType.error => Icons.error_outline_rounded,
      UISnackBarType.success => Icons.check_circle_rounded,
    },
    color: CupertinoColors.white,
    size: Theme.of(context).iconTheme.size,
  );
}
