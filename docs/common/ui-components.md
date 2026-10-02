# Shared UI Components

Import reusable widgets through `package:ui/ui.dart`. The application owns business state and routing; the UI package
owns presentation. The UI example uses Tetradka's searchable category catalog, with a phone navigation flow and a
persistent wide navigation pane. It includes interactive button, loading, Rive status, avatar, price, text counter,
list, input, color picker, sticky group, flyout, and in-memory image editor previews.

## Buttons

`UIButton` extends the SDK ButtonStyleButton. Primary, secondary, icon and secondary-icon constructors share
UI theme metrics. `UIButton.styleFrom` creates partial overrides; resolution follows widget style, FilledButtonTheme,
then UI defaults. The button is enabled when either `onPressed` or `onLongPress` is supplied; `loading: true` disables both. Loading keeps the label's
layout and semantics while displaying an indicator. Button heights are minimums so scaled labels can grow.
Callers own outer Padding/SizedBox/Expanded, focus nodes and optional WidgetStatesController instances.
No Liquid Glass or surface-style subsystem is required.

## Loading Scopes And Operation Feedback

`UILoadingController.run` starts each action immediately and tracks it by a distinct token. Overlapping actions
remain active independently; results and errors propagate unchanged. The controller owns presentation state only,
not domain results, retries or cancellation. `message` is explicit only for one active action; concurrent actions
use a localized default. Lazy work participates unless a UILoadingTitle has `showLazyLoading: false`.

`UILoadingScope` owns a controller only when one is not provided. External controllers remain caller-owned.
Replacing or removing a scope does not cancel its actions; late completions do not notify a disposed controller.
`UILoadingScope.of` issues commands without subscribing the whole screen. UILoadingTitle observes only its own
presentation, supports bounded text, and skips visual motion when requested by the platform.

Install `UIScope` in MaterialApp.builder, above the navigator. Descendants use
`UIOperationStatusMessenger.of(context)` to show loading, determinate progress, success, error, info, toast or custom
content. A new show supersedes the previous panel and its timer. Show/dismiss futures describe transitions, not
the caller's operation completion. Issue commands from handlers, not build. The caller remains responsible for
preventing an older application operation from issuing a newer status command.

Loading/progress remain visible until replaced or dismissed unless a duration is supplied. Results/toasts expire
after two seconds by default. Blocking, pointer/Escape dismissal, custom indicators and durations are caller-owned
choices. Blocking panels exclude the underlying focus/semantics; dismissal restores prior focus where possible.
The host retains its child across panel updates. Toast placement accounts for safe areas, keyboard and bottom chrome.

`UIOperationStatusIndicatorStyle.standard` is the default. Select `rive` through UIScope or the messenger constructor
to initialize the [Rive runtime](https://rive.app/docs/runtimes/flutter/flutter) on the first loading/success/error
panel and load the bundled `packages/ui/assets/check_error.riv` once per host. An idle host, progress, toast and
explicit custom indicators do not initialize Rive. The file remains alive until its indicator controllers unmount.
Late decoded files are released after disposal. Progress, unsupported phases, reduced motion, missing triggers and
load failures use the standard renderer. The UI example exposes a standard/Rive renderer switch in Feedback and
defaults to standard; the application installs a standard host.
Existing EasyLoading callers remain independent and are not silently redirected.

## Image Sources, Avatars And Color Helpers

`UIImageSource` distinguishes network, bundle asset and local XFile inputs. Network/asset sources compare their
locations; local sources compare XFile identity so same-name in-memory files cannot hide replacement content.
Compatibility location helpers do not convert arbitrary browser paths into native filesystem objects.

`UIAvatar` uses typed sources, up to two Unicode grapheme initials, or the shared fallback icon. Raster sources can
use a typed `sourceRect`; SVG assets render as vectors without raster cropping. Loading/read/decode failures fall
back to initials or the icon. Network rendering enables the existing ExtendedImage cache, matching the source's cached native rendering;
Web persistence remains the browser's responsibility. Typed `source`/`sourceRect` take precedence over compatibility
`image`/`crop` values. `status`, `statusBorderColor` and `UIAvatarStatusType` restore the source status badge contract;
a custom `badge` overrides the status badge. `imageEmpty` remains an unused source compatibility argument.
`UIAvatar.circle` clips only the image, preserving badges.

`UIAvatarWithLoader` presents an editable avatar and processing badge. Its `onPick` callback returns a confirmed
`UIMediaSelection` or null on cancellation; the application owns camera/gallery capabilities, permissions and crop
navigation. `onChanged` observes a confirmed selection and `onDelete` observes deletion. The local preview updates
immediately, but a new source/crop replaces it. Source replacement or disposal discards late picker results.
Processing disables editing and preserves the current image. This port intentionally does not retain the source's
app-specific `rootContext`, `debug` or `fixGesturePosition` arguments or its internal ImagePicker/permission flow.

`UIColorUtil` provides strict hexadecimal parsing/serialization, HSL darken/lighten and foreground selection by
WCAG luminance contrast. Supply an opaque backdrop for translucent backgrounds; translucent candidates are
composited before comparison. The helper chooses the better candidate; it cannot promise that either passes a
particular [WCAG contrast threshold](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html).
The application-specific `ColorUtil.getColors` remains unchanged.

## Price Formatting And Text Counters

`TextInputFormatter$Price` accepts digits, an optional leading minus and one decimal separator. Output uses spaces
for thousands and comma for fractions; `decimalDigits` defaults to two, accepts null for unlimited fractions and
zero for integers. Unlimited mode retains the source formatter's trailing-zero normalization. It preserves active
[IME composition](https://api.flutter.dev/flutter/services/TextInputFormatter-class.html), maps caret/selection
positions and handles backspacing across grouping spaces. `formatRaw`, `formatInitial` and `apply` format initial
controller content; apply leaves active composition untouched. This is presentation formatting, not a money model
or a locale-aware currency parser.

`UITextFieldCounterWrapper` listens only around the counter, counts Unicode graphemes, and appears when at most
50 characters remain. It does not enforce a limit or own its controller. Negative values expose overflow; the
caller supplies placement and decides how the field enforces or validates its maximum.

## List Rows And Sections

`UIListTile` and `UIListSection` are adapted from Tetradka's `ziqq/github-597/ui-list-components` branch.
Rows accept caller-owned title, subtitle, leading, trailing and actions. `UIListTile.selectable` uses
`CupertinoMenuAnchor`; callers supply the menu entries. Keep the headless `UIFlyout` for custom overlay content.

Sections use `CupertinoListSection.insetGrouped`, with nullable string `header` and `footer`. Headers are uppercase.
`UIListSection.secondary` selects the secondary surface. `contentPadding` maps to the SDK section margin;
`dividerMargin` is directional. With `useSeparator: false`, a single Column removes divider layout as well as paint.
The inset-grouped SDK owns the corner geometry; the API does not advertise an unsupported radius override.

The previous `secodary`, `textHeader` and `textFooter` API has been migrated to `secondary`, `header` and `footer`.
Cupertino form-row wrappers are not part of the template.

## Text, Search And Password Inputs

`UITextInput` delegates editing, focus, validation, reset, autofill, selection and error layout to
[TextFormField](https://api.flutter.dev/flutter/material/TextFormField-class.html) and InputDecoration.
Borders, label/hint colors, platform padding and suffix geometry follow Tetradka's appearance. Its height is a minimum; multiline content, errors and text scaling can grow. There is no field background painter
or listener rebuilding the entire form. SDK callback types, `onSaved`, `autovalidateMode` and `restorationId` are exposed.
`errorText` is the SDK's forced error state, so it overrides the validator until the caller clears it.

External controllers and focus nodes remain caller-owned. `controller` and `initialValue` are mutually exclusive;
without a controller the wrapper owns a RestorableTextEditingController and the SDK owns Form state. `initialValue` does not overwrite edits
on later rebuilds. A clear action appears only for nonempty editable text, with or without an external controller; `onChanged('')` and
`onClearTap` observe the clear. `displayText` is for a controlled read-only value and cannot use a controller or initialValue.
`UITextInput.offsetless` removes the default bottom spacing.

`UISearchInput` preserves Tetradka's SDK `CupertinoSearchTextField`, including its compact geometry, background,
prefix/loading icon and clear suffix visible only for a nonempty query. It owns its controller only when none is provided. Replacing an external controller with an internal one
preserves its editing value. Clear always clears the query, invokes `onChanged('')` once for a nonempty query and then
`onSuffixTap`, regardless of controller ownership. Loading replaces only the search icon.

`UIPasswordInput` keeps visibility state and delegates editing to UITextInput. It has no unused shadow controller;
its visibility action is a localized IconButton. Suggestions and autocorrection are disabled; password autofill is
enabled and can be replaced with `AutofillHints.newPassword` by a signup form.

## PIN Input And Shake Feedback

`UIPinInput` uses one SDK text field with paint-only digit cells, not one controller per digit. Callers own the
required controller and focus node, plus optional verified/failed listenables. User edits accept ASCII digits and
preserve leading zeros; programmatic text must already satisfy the length/digit contract. Completion alone does not
imply server acceptance. The caller decides when to submit and updates result flags. PIN length and separator are configurable.
Autofill, paste and platform editing menus use the SDK field. Reduced motion skips visual transitions.

`UIShakeController` separates error state from its shake signal. Repeating a failed submit can shake again;
clearing an error does not replay motion. The transition disposes its animations and rebinds a replaced controller.
Callers dispose their controller. Haptics are opt-in and reduced motion is respected by default.

## Color Picker And Grouped Slivers

`UIColorPicker` accepts RGB/RRGGBB/AARRGGBB strings and a selected index. A null callback disables selection;
empty colors produce no widget. Duplicate values remain separate indexed swatches. The grid requires bounded width;
`horizontal` gives a scrolling list. Without `bulletSize`, grid swatches fill their cells; an explicit diameter controls
column capacity. Spacing, padding and the 2 px selection inset follow Tetradka. Pointer, keyboard focus and selection
semantics use SDK Material controls. Very narrow cells can be smaller than the SDK minimum touch target.

`UIGroupedSliverList` belongs directly in a CustomScrollView's slivers. The normal variant uses persistent headers;
`sticky` uses intrinsic headers that hand off at section boundaries while list children remain lazy.
Treat items and their payloads as immutable and pass a new list after changes. Equal group keys merge even across
pages. Null group keys are skipped. Optional sort keys sort globally in descending order; null sort keys are skipped.
Unsorted appends can reuse groups; sorted updates regroup globally. Replacing an extractor invalidates grouping.
Header and list keys include actual group keys, not only their hash codes.

## Flyouts

`UIFlyout` is a controlled, headless overlay. The caller supplies `isOpen`, `flyoutBuilder`, and the anchor widget.
`UIFlyoutAnchor` controls directional alignments and offset. `UIFlyoutWidth.fill` follows the anchor width, constrained
to the overlay bounds. Overflow first tries the opposite side, then clamps the surface to the overlay.

The nearest `Overlay` owns the portal. Flutter's
[`OverlayPortal.overlayChildLayoutBuilder`](https://api.flutter.dev/flutter/widgets/OverlayPortal/OverlayPortal.overlayChildLayoutBuilder.html) supplies current target
bounds during layout; no scroll observer or manual global-coordinate polling is required. Ordinary scroll, scale,
translation, RTL, and viewport changes are handled by layout. Do not put this widget below a `CompositedTransformFollower`:
that paint transform is established after layout, which this SDK API cannot resolve.

Removing the anchor removes its overlay. Callers own focus, semantics, keyboard shortcuts, outside-tap dismissal,
safe-area/keyboard-aware presentation, and any route-change dismissal. The example demonstrates a modal barrier,
focus scope, and Escape shortcut. Backdrop bounds are in overlay coordinates.

## Image Editor

`UIImageEditor` reads `XFile.readAsBytes` on native and web, including `XFile.fromData`. It caches the read until the
file instance changes and shows loading or a broken-image indicator on failure. It does not interpret browser paths
as filesystem paths. `UILocalImage` remains the existing local-image renderer.

Present `UIImageEditorScreen` as a temporary Flutter-owned route and await its `Rect` result. Cancellation returns
`null`; confirmation also invokes the optional `onChanged` callback once. An avatar uses a square crop and circular
preview mask; a rectangular crop uses the requested positive aspect ratio. The navigation bar uses the screen background
explicitly, with automatic background switching and blur disabled, so it does not inherit a mismatched Cupertino surface.

```dart
final crop = await Navigator.of(context).push<Rect>(
  MaterialPageRoute<Rect>(
    fullscreenDialog: true,
    builder: (_) => UIImageEditorScreen(file: file),
  ),
);
if (crop != null) {
  final selection = UIMediaSelection(file: file, crop: crop);
  // Pass the original file and source-pixel bounds to the owning workflow.
}
```

Crop coordinates refer to the decoded source image, not logical layout pixels. Neither the editor nor
`UIMediaSelection` re-encodes the file or applies a circular mask to its bytes. The caller owns encoding, upload,
permission handling, and any backend-specific crop contract. Full-resolution bytes and decoding can require substantial
memory for large photos; measure representative inputs before adopting the editor in a photo-heavy workflow.

## Verification

Run `mise exec -- make format`, `mise exec -- make check`, and `mise exec -- make test-unit-all`.
Check the example on native and web. New regression tests are added only after approval of the main implementation.
