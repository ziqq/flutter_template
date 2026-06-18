import 'package:flutter/widgets.dart' show Locale, LocalizationsDelegate;
import 'package:flutter_template_name/src/common/localization/localization.dart' show Localization;
import 'package:ui/ui.dart' show UILocalizations;

/// Override for [UILocalizations] with app-specific strings.
class OverrideUILocalizations extends UILocalizations {
  const OverrideUILocalizations(this._l10n, this._fallback);

  final /* AppLocalization */ Localization _l10n;
  final UILocalizations _fallback;

  @override
  String get backButton => _l10n.backButton;

  @override
  String get cancelButton => _l10n.cancelButton;

  @override
  String get editButton => _l10n.editButton;

  @override
  String get closeButton => _fallback.closeButton;

  @override
  String get deleteButton => _l10n.deleteButton;

  @override
  String get doneButton => _fallback.doneButton;

  @override
  String get moreLabel => _fallback.moreLabel.toLowerCase();

  @override
  String get actionNext => _fallback.actionNext;

  @override
  String get notNowButton => _fallback.notNowButton;

  @override
  String get actionPhotoMake => _fallback.actionPhotoMake;

  @override
  String get actionPhotoSelectFromGallery => _fallback.actionPhotoSelectFromGallery;

  @override
  String get selectLabel => _fallback.selectLabel;

  @override
  String get actionTurnLeft => _fallback.actionTurnLeft;

  @override
  String get actionTurnRight => _fallback.actionTurnRight;

  @override
  String get labelCalendar => _fallback.labelCalendar;

  @override
  String get labelDate => _fallback.labelDate /* _l10n.dateLabel */;

  @override
  String get labelDuration => _fallback.labelDuration;

  @override
  String get textGenderFemale => _fallback.textGenderFemale;

  @override
  String get textGenderMale => _fallback.textGenderMale;

  @override
  String get labelGender => _fallback.labelGender;

  @override
  String get phoneLabel => _fallback.phoneLabel;

  @override
  String get labelSettings => _fallback.labelSettings;

  @override
  String get todayLabel => _fallback.todayLabel;

  @override
  String get language => _l10n.language;

  @override
  String get loading => _fallback.loading;

  @override
  String get requestPermissionPhotos => _fallback.requestPermissionPhotos;

  @override
  String get requestPermissionTitle => _fallback.requestPermissionTitle;

  @override
  String get screenEditPhotoTitle => _fallback.screenEditPhotoTitle;

  @override
  String get textIsBlocked => _fallback.textIsBlocked;

  @override
  String get textIsOnline => _fallback.textIsOnline;

  @override
  String get textNoValue => _fallback.textNoValue;

  @override
  String get notSelectedLabelMasculine => _fallback.notSelectedLabelMasculine;

  @override
  String get notSelectedLabelFeminine => _fallback.notSelectedLabelFeminine;

  @override
  String get notSelectedLabelNeuter => _fallback.notSelectedLabelNeuter;

  static const delegate = _OverrideUILocalizationsDelegate();
}

/// A [LocalizationsDelegate] to load [OverrideUILocalizations].
class _OverrideUILocalizationsDelegate extends LocalizationsDelegate<UILocalizations> {
  const _OverrideUILocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => Localization.delegate.isSupported(locale);

  @override
  Future<UILocalizations> load(Locale locale) async {
    final fallback = await UILocalizations.delegate.load(locale);
    final l10n = await /* AppLocalization */ Localization.delegate.load(locale);
    return OverrideUILocalizations(l10n, fallback);
  }

  @override
  bool shouldReload(covariant _OverrideUILocalizationsDelegate old) => false;
}
