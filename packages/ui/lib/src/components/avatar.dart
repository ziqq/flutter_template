import 'dart:convert' show jsonDecode;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        CupertinoColors,
        CupertinoDynamicColor,
        showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui/src/components/border_radius.dart';
import 'package:ui/src/components/icons/avatar_icon.dart';
import 'package:ui/src/components/loader_indicator.dart';
import 'package:ui/src/components/local_image.dart';
import 'package:ui/src/localization/localization.dart';
import 'package:ui/src/media/image_source.dart';
import 'package:ui/src/media/media_selection.dart';
import 'package:ui/src/theme/theme.dart';
import 'package:ui/src/utils/color_util.dart';

/// Displays a typed image, Unicode initials, or the shared fallback icon.
///
/// [sourceRect] is a rectangle in decoded raster-image pixels, as returned by
/// the image editor. It does not modify or encode the underlying file. SVG
/// assets render as vectors and do not use raster crop coordinates.
/// The caller owns selection, upload, navigation and an optional [badge].
class UIAvatar extends StatelessWidget {
  const UIAvatar({
    this.source,
    this.image,
    this.imageEmpty,
    this.crop,
    this.status,
    this.statusBorderColor,
    this.fromLocalPath = false,
    this.name,
    this.size,
    this.sourceRect,
    this.borderRadius,
    this.badge,
    this.semanticLabel,
    this.useDarkMode,
    this.rounded = false,
    super.key,
  }) : assert(size == null || size > 0 && size < double.infinity, 'Size must be positive and finite.');

  const UIAvatar.circle({
    this.source,
    this.image,
    this.imageEmpty,
    this.crop,
    this.status,
    this.statusBorderColor,
    this.fromLocalPath = false,
    this.name,
    this.size,
    this.sourceRect,
    this.borderRadius,
    this.badge,
    this.semanticLabel,
    this.useDarkMode,
    super.key,
  }) : rounded = true,
       assert(size == null || size > 0 && size < double.infinity, 'Size must be positive and finite.');

  final UIImageSource? source;
  final String? image;
  final String? imageEmpty;
  final String? crop;
  final String? status;
  final Color? statusBorderColor;
  final bool fromLocalPath;
  final String? name;
  final double? size;
  final Rect? sourceRect;
  final BorderRadius? borderRadius;
  final Widget? badge;
  final String? semanticLabel;
  final bool? useDarkMode;
  final bool rounded;

  /// The theme-derived fill behind initials.
  static Color emptyBackgroundColorWithName(BuildContext context) {
    final theme = Theme.of(context);
    return UIColorUtil.lighten(theme.dividerColor, theme.brightness == Brightness.dark ? 0.15 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diameter = size ?? theme.uiTheme.size.avatar.regular;
    final radius = borderRadius ?? (rounded ? BorderRadius.circular(diameter / 2) : UIBorderRadius.regular(context));
    final words = name?.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList(growable: false);
    final fallback = words == null || words.isEmpty
        ? UIIcon$Avatar(
            size: diameter,
            brightness: useDarkMode == null ? null : (useDarkMode! ? Brightness.dark : Brightness.light),
          )
        : _AvatarInitials(
            initials: words.take(2).map((word) => word.characters.first.toUpperCase()).join(),
            diameter: diameter,
          );
    final effectiveSource =
        source ?? UIImageSource.fromLocations(localPath: fromLocalPath ? image : null, location: image);
    final crop = sourceRect ?? _parseCrop(this.crop);
    final validCrop = crop != null && crop.isFinite && !crop.isEmpty && crop.left >= 0 && crop.top >= 0 ? crop : null;
    return SizedBox.square(
      dimension: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Semantics(
            image: true,
            label: semanticLabel ?? name,
            child: ExcludeSemantics(
              child: ClipRRect(
                borderRadius: radius,
                child: _AvatarImage(
                  source: effectiveSource,
                  sourceRect: validCrop,
                  diameter: diameter,
                  fallback: fallback,
                ),
              ),
            ),
          ),
          if (badge != null || status != null)
            PositionedDirectional(
              end: -3,
              bottom: -3,
              child:
                  badge ??
                  _AvatarStatus(
                    status: UIAvatarStatusType.fromString(status!),
                    diameter: diameter,
                    borderColor: statusBorderColor,
                  ),
            ),
        ],
      ),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.initials, required this.diameter});

  final String initials;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = UIAvatar.emptyBackgroundColorWithName(context);
    return ColoredBox(
      color: background,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(diameter / 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              initials,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: diameter / 2.5,
                color: UIColorUtil.contrastingForegroundColor(
                  background,
                  backdropColor: theme.uiTheme.color.background,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.source, required this.sourceRect, required this.diameter, required this.fallback});

  final UIImageSource? source;
  final Rect? sourceRect;
  final double diameter;
  final Widget fallback;

  @override
  Widget build(BuildContext context) => switch (source) {
    UIImageSource$Local(:final file) => UILocalImage(
      file: file,
      width: diameter,
      height: diameter,
      sourceRect: sourceRect,
      placeholder: fallback,
    ),
    UIImageSource$Network(:final url) => ExtendedImage.network(
      url,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
      cache: true,
      loadStateChanged: _loadStateChanged,
    ),
    UIImageSource$Asset(:final path) when path.endsWith('.svg') => SvgPicture.asset(
      path,
      fit: BoxFit.cover,
      width: diameter,
      height: diameter,
      placeholderBuilder: (_) => fallback,
      errorBuilder: (_, _, _) => fallback,
    ),
    UIImageSource$Asset(:final path) => ExtendedImage.asset(
      path,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
      loadStateChanged: _loadStateChanged,
    ),
    null => fallback,
  };

  Widget _loadStateChanged(ExtendedImageState state) => switch (state.extendedImageLoadState) {
    LoadState.loading || LoadState.failed => fallback,
    LoadState.completed => ExtendedRawImage(
      image: state.extendedImageInfo?.image,
      width: diameter,
      height: diameter,
      fit: BoxFit.cover,
      sourceRect: sourceRect,
    ),
  };
}

Rect? _parseCrop(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    final Object? decoded = jsonDecode(value);
    if (decoded case <String, Object?>{'x': num x, 'y': num y, 'width': num width, 'height': num height}) {
      return Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
    }
  } on FormatException {
    return null;
  }
  return null;
}

/// Status values accepted by the compatibility [UIAvatar.status] API.
enum UIAvatarStatusType {
  blocked('blocked'),
  review('review'),
  reminder('reminder'),
  done('done'),
  working('working'),
  isNew('new');

  const UIAvatarStatusType(this.value);

  factory UIAvatarStatusType.fromString(String value) => switch (value) {
    'blocked' => blocked,
    'review' => review,
    'reminder' => reminder,
    'done' => done,
    'working' => working,
    _ => isNew,
  };

  final String value;

  @override
  String toString() => value;
}

class _AvatarStatus extends StatelessWidget {
  const _AvatarStatus({required this.status, required this.diameter, this.borderColor});

  final UIAvatarStatusType status;
  final double diameter;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      UIAvatarStatusType.blocked => (Icons.block, CupertinoColors.systemRed),
      UIAvatarStatusType.review => (Icons.star_border_rounded, CupertinoColors.systemOrange),
      UIAvatarStatusType.reminder => (Icons.schedule, CupertinoColors.systemYellow),
      UIAvatarStatusType.done => (Icons.check_circle_outline, CupertinoColors.systemGreen),
      UIAvatarStatusType.working => (Icons.update_outlined, CupertinoColors.systemOrange),
      UIAvatarStatusType.isNew => (Icons.watch_later_outlined, CupertinoColors.systemBlue),
    };
    return SizedBox.square(
      dimension: diameter / 2.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: borderColor ?? Theme.of(context).uiTheme.color.surface,
          border: Border.all(color: borderColor ?? Theme.of(context).uiTheme.color.surface),
        ),
        child: Icon(icon, size: diameter / 3, color: CupertinoDynamicColor.resolve(color, context)),
      ),
    );
  }
}

/// An editable avatar with a loading badge and caller-owned media selection.
///
/// [onPick] owns permissions, camera/gallery selection and crop navigation. It
/// returns null on cancellation. [onChanged] receives a confirmed selection;
/// the widget never uploads, encodes or serializes it. Updating [source] replaces
/// a local preview and invalidates any outstanding picker result.
class UIAvatarWithLoader extends StatefulWidget {
  const UIAvatarWithLoader({
    this.source,
    this.image,
    this.name,
    this.sourceRect,
    this.onPick,
    this.onChanged,
    this.onDelete,
    this.borderRadius,
    this.addButtonSize,
    this.borderColor,
    this.borderPadding,
    this.semanticLabel,
    this.size = 56,
    this.rounded = false,
    this.processing = false,
    this.fromLocalPath = false,
    super.key,
  }) : assert(size > 0 && size < double.infinity, 'Size must be positive and finite.'),
       assert(
         addButtonSize == null || addButtonSize > 0 && addButtonSize < double.infinity,
         'Badge size must be positive and finite.',
       );

  final UIImageSource? source;
  final String? image;
  final String? name;
  final Rect? sourceRect;
  final Future<UIMediaSelection?> Function()? onPick;
  final ValueChanged<UIMediaSelection>? onChanged;
  final VoidCallback? onDelete;
  final BorderRadius? borderRadius;
  final double? addButtonSize;
  final Color? borderColor;
  final EdgeInsetsGeometry? borderPadding;
  final String? semanticLabel;
  final double size;
  final bool rounded;
  final bool processing;
  final bool fromLocalPath;

  @override
  State<UIAvatarWithLoader> createState() => _UIAvatarWithLoaderState();
}

class _UIAvatarWithLoaderState extends State<UIAvatarWithLoader> {
  UIMediaSelection? _selection;
  bool _deleted = false;
  bool _selecting = false;
  int _generation = 0;

  UIImageSource? get _source => _deleted
      ? null
      : _selection == null
      ? widget.source ??
            UIImageSource.fromLocations(localPath: widget.fromLocalPath ? widget.image : null, location: widget.image)
      : UIImageSource.local(_selection!.file);

  @override
  void didUpdateWidget(covariant UIAvatarWithLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source ||
        oldWidget.image != widget.image ||
        oldWidget.fromLocalPath != widget.fromLocalPath ||
        oldWidget.sourceRect != widget.sourceRect) {
      _generation++;
      _selection = null;
      _deleted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).uiTheme;
    final busy = widget.processing || _selecting;
    final hasActions = widget.onPick != null || widget.onDelete != null && _source != null;
    final radius =
        widget.borderRadius ??
        (widget.rounded ? BorderRadius.circular(widget.size / 2) : UIBorderRadius.regular(context));
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: widget.borderColor ?? theme.color.background,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: hasActions && !busy ? _selectImage : null,
              child: Padding(
                padding: widget.borderPadding ?? EdgeInsets.zero,
                child: UIAvatar(
                  source: _source,
                  name: _deleted ? null : widget.name,
                  sourceRect: _selection?.crop ?? widget.sourceRect,
                  size: widget.size,
                  borderRadius: radius,
                  semanticLabel: widget.semanticLabel,
                ),
              ),
            ),
          ),
          if (hasActions || busy)
            PositionedDirectional(
              end: widget.rounded ? -5 : -10,
              bottom: widget.rounded ? -5 : -10,
              child: Material(
                color: theme.color.surface,
                elevation: 2,
                borderRadius: BorderRadius.circular(theme.size.corner.regular),
                child: SizedBox.square(
                  dimension: widget.addButtonSize ?? widget.size / 2.8,
                  child: busy
                      ? Padding(
                          padding: EdgeInsets.all(widget.size / 10),
                          child: const UILoaderIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          tooltip: UILocalizations.of(context).editButton,
                          padding: EdgeInsets.zero,
                          iconSize: widget.size / 4,
                          onPressed: _selectImage,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    if (widget.processing || _selecting) return;
    final pick = widget.onPick;
    final generation = _generation;
    final l10n = UILocalizations.of(context);
    setState(() => _selecting = true);
    try {
      final edit = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            if (pick != null)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.editButton),
              ),
            if (widget.onDelete != null && _source != null)
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.deleteButton),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelButton),
          ),
        ),
      );
      if (!mounted || generation != _generation || widget.processing) return;
      if (edit == false) {
        setState(() {
          _selection = null;
          _deleted = true;
        });
        widget.onDelete?.call();
      } else if (edit == true && pick != null && pick == widget.onPick) {
        final selection = await pick();
        if (!mounted || generation != _generation || pick != widget.onPick || selection == null) return;
        setState(() {
          _selection = selection;
          _deleted = false;
        });
        widget.onChanged?.call(selection);
      }
    } finally {
      if (mounted) setState(() => _selecting = false);
    }
  }
}
