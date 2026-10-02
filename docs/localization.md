# Localization

The template owns its ARB sources in `lib/src/common/localization/translations/`:

- `intl_en.arb`: English.
- `intl_ru.arb`: Russian.

Run `mise exec -- make l10n` after changing an ARB source, or `mise exec -- make gen` for all generators.
The workflow uses the pinned `intl_utils` dependency and Flutter's `gen-l10n` command. Generated output belongs in
`lib/src/common/localization/generated/` and must not be edited manually.

The application localization adapter implements the UI package's localization interface. Keep UI text in this interface
or ARB sources instead of hard-coding application strings in widgets.

This template has no Google Sheets integration or `packages/localization` workspace member. A downstream application
may introduce one, but it must supply its own configuration and credentials; do not copy another application's Sheet ID.
