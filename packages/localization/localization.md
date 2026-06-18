# Localization

This is localization package for the app.

It contains all the localization-related code,
including the generated localization files and the localization overrides.

Usually, you don't need to modify this package, unless you want to add new localization strings or override existing ones. You should add new localization strings to the Google Sheets document, and then run the `localization` script to generate the localization files.

Usually here you should place the localization package based on the [sheety_localization](https://pub.dev/packages/sheety_localization) package. This package is used to generate the localization files from the Google Sheets document.