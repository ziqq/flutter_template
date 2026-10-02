# UI example

The interactive catalog adapts Tetradka's example shell to the public components available in this template.
It does not import application features or call a backend.

- At widths up to 600 logical pixels, the home screen lists categories and opens a selected category as an SDK route.
- Wider layouts keep searchable navigation beside the preview, with a 260 px tablet pane or a 320 px pane from 1024 px.
- `lib/src/catalog/` owns category metadata and navigation; `lib/src/widgets/` owns interactive previews.
- The shell and preview sections use the active UI theme's surfaces, borders, typography, spacing, and corner tokens.
- Input previews follow Tetradka's labeled component groups: two columns from 680 px of content width and a vertical stack below it.
- The fixed category app bar stays outside the preview scroll view so pinned section headers remain visible below it.
- Shared UIThemeData maps Material foreground and outline colors to UI tokens; the example needs no local theme workaround.

| Category | Interactive scenarios |
| --- | --- |
| Media | XFile/SVG avatars, typed overlapping avatar collections, initials, crop, replacement, contrast, and editor |
| Inputs | Text/search/password, PIN, color, generic selection with validation/reset/option replacement, price, grapheme count |
| Feedback | Grouped shimmer and content/empty/error/retry, scoped regular/lazy loading, operation status and Rive |
| Buttons | Primary/secondary sizes, disabled/loading, icon and long-press actions |
| Typography | Theme hierarchy, wrapping/ellipsis, selection, expandable text, styled tags and inline actions |
| Icons | Render-object icons; optional configured icon font |
| Lists | SDK sections/rows, sticky groups, pagination footer, empty/error/retry, swipe delete and restore |
| Colors | Light and dark semantic palettes |
| Tokens | Spacing, corners, button/icon/avatar sizes |
| Chips | Tags, controlled choice, removable filters, online/blocked statuses, horizontal collection |
| Pickers | SDK single date, two-tap date range, confirmed date/time and duration, clear |
| Charts | Empty/single/many segments, changing data, selection and tooltip |
| Sheets | Snap points, pinned actions, keyboard form, typed result/cancellation and dismissal modes |
| Motion | Press, repeated shake, notification count, expansion, curves, reduced motion |
| Overlays | Flyouts near edges and while scrolling, repeatable three-step onboarding |
| Accessibility | Text scale 1–2×, RTL, long labels, keyboard focus and a working form |

Search matches titles and descriptions. Its clear action restores all categories. Up/Down move focus through the
visible categories; Ctrl/Cmd+F focuses search. The theme action switches light/dark themes.

The Feedback category selects the root operation renderer, standard by default, or bundled Rive. Block interaction,
tap/Escape dismissal, messages, progress, and toast status are caller-owned demo settings. Status previews expire after
three seconds, including blocking ones. Only the controls observing a setting listen to it; changing the renderer
retains the navigator child. All settings and sample data live only for the example process.

Liquid Glass, Cupertino form rows, phone masks, application scheduling models, Syncfusion calendars, and duplicate legacy components are not imported.
Date ranges use Flutter `DateTimeRange`; the inline demo selects start/end in two taps and displays the confirmed range as text.

Run from this directory:

```sh
mise exec -- flutter run -d chrome
mise exec -- flutter build web --release
```

## Verification

Run workspace validation from the repository root with `mise exec -- make format`, `mise exec -- make check`, and
`mise exec -- make test-unit-all`. The widget entry points include regression checks for controller ownership,
selection reset/replacement, search clearing, password focus/selection, overlapping loading, late async completion,
tour callback replacement, shimmer scope changes, and focused input layout with growing keyboard insets.

Native scenarios live in `integration_test/catalog_native_test.dart`. From this directory, choose an explicit device
from `mise exec -- flutter devices` so the runner cannot select another simulator:

```sh
mise exec -- dart format --line-length 120 integration_test
mise exec -- flutter analyze integration_test --fatal-warnings --fatal-infos
mise exec -- flutter test integration_test/catalog_native_test.dart -d "<device-id>" --reporter expanded
```

These tests cover native sheet validation/results and duration cancellation/confirmation. The Android-only test
requires a real visible IME and checks the focused editor and pinned Save action against its actual bounds. It is
skipped on iOS, where a simulator's connected hardware keyboard can hide the software keyboard. A widget test with
injected insets is useful regression coverage but does not replace native keyboard acceptance.

| Validation on 2026-10-02 | Result and boundary |
| --- | --- |
| Workspace format, analysis, unit/widget tests | Passed; eight additional component contract tests and one keyboard layout regression |
| iPhone Air, iOS 26.5 Simulator | Native build passed; sheet validation/result and duration Cancel/Done passed; Android IME case skipped |
| Air catalog interactions | Light/dark surfaces, typed sheet result, duration wheel, tour completion/restart/cancel, anchored menu, loading/content/error/retry, reduced-motion notification actions, and bundled Rive success status checked |
| SM-A530F, Android 9 / API 28 | All three native scenarios passed, including the real IME bounds check |
| Screen readers and performance | VoiceOver/TalkBack acceptance and frame/memory measurements not performed |

Native screen-reader behavior and physical-device performance need separate checks; the catalog alone is not evidence
for them. Android builds currently warn that `rive_native` applies Kotlin Gradle Plugin and will need compatibility
with Flutter's future Built-in Kotlin requirement. This warning does not currently prevent the native test build.
