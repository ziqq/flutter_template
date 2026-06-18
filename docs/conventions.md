# Style, blowtorch, prohibitions


## Generated artifacts (do not edit)
The following paths/files are generated and MUST NOT be edited manually:

- `packages/localization/**` — **ALL files** are generated from Google Sheets.
  Update the sheet and run generation via: `.vscode/tasks.json` → `dart:sheety_localization:generate` (see `docs/localization.md`).
- `**/generated/**`
- `**/*.g.dart`
- `**/*.gen.dart`
- `**/*.freezed.dart`
- `**/*.mocks.dart`

If changes are required:
1) change the authoritative input (Google Sheet / generator),
2) run generation,
3) commit regenerated outputs.


## Icons (authoritative)

### Font icons (monochrome)
The icon font `packages/ui/lib/fonts/icomoon.ttf` is used as a replacement for monochrome vector icons.

To convert SVGs into a font, use: https://icomoon.io

The latest configuration is stored in: `packages/ui/lib/fonts/icomoon.json`

Rule:
- after each font update you MUST update `packages/ui/lib/fonts/icomoon.json`.

### CustomPaint / RenderObject icons (multicolor SVG)
All SVG icons with more than one color should be converted into `CustomPaint` (or RenderObject-based icons, if needed by UI layer).

Tool: [fluttershapemaker.com](https://fluttershapemaker.com)

### Raster-like icons
If the icon resembles a raster image with a large number of colors, convert it to `webp`.


## Vendor / platform folders (do not edit)
- `.dart_tool/**`
- `.coverage/**`
- `coverage/**`
- `android/.gradle/**`
- `android/.kotlin/**`
- `android/gradlew**`
- `android/gradlew.*`
- `android/key.properties`
- `android/local.properties`
- `ios/Pods/**`
- `build/**`
- `reports/**`


## Database DDL naming

All database DDL identifiers in the project must use `snake_case`.

This applies to:

- table names
- column names
- index names
- trigger names

Do not introduce feature-specific exceptions for DDL naming.