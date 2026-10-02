# UI package

Reusable presentation components for mobile, web, and desktop applications. Import `package:ui/ui.dart`.
The interactive catalog lives in `example/` and has no backend or persistent demo state.

## Catalog expansion contract

Adapt the Tetradka catalog by capability: Colors, Tokens, Charts, Sheets, Motion, Accessibility, Feedback, Lists,
Overlays, Inputs, Pickers, Chips, Typography, Buttons, Icons, and Media. Keep template-specific public APIs and the
fixed application version. Liquid Glass, Cupertino form rows, phone masks, business calendars, and old modal-sheet
implementations are outside this migration.

Component transfers include generic selection, shared shimmer, lazy loading, expandable/tagged text, onboarding,
chips, date/duration pickers, animated notification buttons, swipe actions, and typed avatar collections.

- Caller-owned controllers and notifiers are never disposed by a widget. Internally owned resources are disposed.
- Selection participates in `Form` validation/reset; empty options and replacement values are safe.
- Date and range types come from Flutter SDK; no Syncfusion dependency or application scheduling data is imported.
- Avatar collections accept `UIImageSource`, including local `XFile` sources, without importing app models.
- Shared shimmer preserves the existing `Shimmer` API and supports ticker/reduced-motion suspension. A keyed shimmer
  can move into and out of a group while retaining its State; its local ticker is disposed when replaced or unmounted.
- Lazy loading guards an in-flight callback and ignores nested scroll notifications.
- Tours and demo work have explicit cancellation/disposal. Every sample action has a visible, local result.
- Existing tests stay unchanged until the main implementation is accepted. Run them to detect regressions.

Acceptance: exports compile, `make format`, `make check`, `make test-unit-all`, example analysis/test/web build,
and browser checks for light/dark themes, narrow/wide constraints, navigation, and representative actions.
Browser and unit checks do not establish native keyboard, screen-reader, or physical-device performance acceptance.
See the [example verification matrix](example/README.md#verification) for device evidence and native test commands.

## Ownership

Application localization remains in the app. Shared control labels use the package's manual `UILocalizations` delegate
with English and Russian defaults. Demo labels and fictional data belong to the example.

Use `UIScope` in `MaterialApp.builder` to host operation status presentation. Rive assets are owned by the package;
callers choose the renderer and interaction policy. Existing `UIImageSource`, `UIAvatar`, `UIListTile`, `UIListSection`,
and `UISheetRoute` contracts are retained.

## Transfer results

| Tetradka component family | Template contract |
| --- | --- |
| Slider theme | Current Tetradka geometry: thumb radius is half the regular icon size, rather than a full button size |
| `UISelect<T>` | SDK `FormField<T>`, caller-owned notifier or value, normalized options, reset, confirmed mobile picker |
| Grouped shimmer | Existing `Shimmer` plus `UIShimmerGroup`; shared clock/shader, reduced-motion and ticker suspension |
| Lazy scrolling | `UILazyLoadScrollView`, `UILazyLoadingIndicator`, `UIListLoaderIndicator`; future guards the request |
| Text | `UITextReadMore` with accessible expansion; `RichTextBuilder` / `RichTextTag` own their recognizers |
| Onboarding | `UIShowcaseController`, sequence, scope, target and action; cancellation, target timeout, no restart on callback replacement |
| Chips | Current tag/choice/filter/status/scrollable APIs; SDK focus and selection, typed filter avatar |
| Pickers | `UISelectDate`, `UIDatePicker`, `UIDateTimePickerRow`; SDK dates/ranges, two-tap inline range, confirmed wheel picker |
| Notifications | `UIAnimatedIconButton`; repeated count animation, no delayed animation chains |
| Swipes | `UISlidable`, `UISlidableAction`; `flutter_slidable`; dismissal requires a caller removal callback |
| Avatar collection | `UIAvatarList` accepts `List<UIImageSource?>`, with direction-aware overlap and hidden count |

`UISelect` compares options by `==`. A notifier's reset value is captured on attachment; replacing the notifier
captures its new initial value. Removed options render as unselected without mutating the notifier during build.
`UISelectDate.value` follows parent updates and its reset callback keeps the caller synchronized.
Range calendars order reversed endpoints; the SDK inline calendar highlights one endpoint and reports the complete
range as text. Duration values are minutes within one day, as supported by `CupertinoTimerPicker`.
`RichTextBuilder` supports non-nested registered tag pairs; unknown markup remains literal text. Custom span builders
own any recognizers they create. `UISlidable.onDismissed` must remove the item from the caller's collection; providing
only `confirmDismiss` does not enable dismissal.
