# Settings

`SettingsController` serializes settings and preference operations through `AppController$Sequential`.
Settings use immutable idle/processing/failed states with error and stack-trace details. A failed save keeps the
previous values; completion returns to idle. Restore retains failure details in the final idle state.

## Storage

`AppSettingsDataProvider` stores locale, theme, accent, and text scale under `${Config.storageNamespace}.settings`.
An optional String `UserID` selects a suffixed key. The current template controller uses the default app-wide key;
this does not introduce account switching. `UserPreferencesDataProvider` stores app-wide flags separately under
`${Config.storageNamespace}.settings.user_preferences`.

The codec accepts legacy bool/int/string flag values and defaults missing keys. New fields are
`useIOS26LiquidTheme` (false) and `analyticsDataSendingEnabled` (true, preserving the source application's default).
The glass flag controls the imported Flutter glass effect in the log toolbar; it is not native iOS Liquid Glass.

## Scope and analytics

`SettingsScope` observes the controller and exposes state, settings, locale, theme, theme mode, and preference aspects.
State consumers observe processing/error transitions even when values have not changed. Other aspects observe their
own slices. The scope retains the template's controller-disposal ownership.

Initialization restores preferences before enabling analytics. Successful consent changes update both the analytics
facade dispatch gate and Firebase collection/consent. Authentication changes identity, not the user's consent setting.
A failed preference write does not change consent. Existing analytics event names and parameter conventions remain.

## Validation

Controller, codec, provider, and repository tests live under `test/src/unit_test/src/feature/settings`.
Widget tests cover consent persistence/failure and selective scope rebuilds; analytics tests cover dispatch gating
and concurrent consent changes. Run `mise exec -- make test-unit-all`.
