import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart' show BuildContext, Locale, Localizations, LocalizationsDelegate;

/// {@template localization}
/// UILocalizations. Localization of UI.
///
/// Follows the same pattern as Material and Cupertino localizations: a manual
/// delegate with built-in English and Russian strings and no `intl` runtime
/// dependency.
/// {@endtemplate}
abstract class UILocalizations {
  /// {@macro localization}
  const UILocalizations();

  String get language;
  String get loading;
  String get backButton;
  String get closeButton;
  String get doneButton;
  String get moreLabel;
  String get actionNext;
  String get cancelButton;
  String get selectLabel;
  String get notNowButton;
  String get deleteButton;
  String get editButton;
  String get actionTurnLeft;
  String get actionTurnRight;
  String get actionPhotoMake;
  String get actionPhotoSelectFromGallery;
  String get labelCalendar;
  String get labelDate;
  String get labelDuration;
  String get labelGender;
  String get phoneLabel;
  String get labelSettings;
  String get todayLabel;
  String get textIsOnline;
  String get textIsBlocked;
  String get textGenderMale;
  String get textGenderFemale;
  String get textNoValue;
  String get notSelectedLabelMasculine;
  String get notSelectedLabelFeminine;
  String get notSelectedLabelNeuter;
  String get requestPermissionTitle;
  String get requestPermissionPhotos;
  String get screenEditPhotoTitle;

  /// UILocalizations delegate.
  static const LocalizationsDelegate<UILocalizations> delegate = _LocalizationView();

  /// Current localization instance.
  static UILocalizations get current => _current;
  static late UILocalizations _current;

  /// Get localization instance for the widget structure.
  static UILocalizations of(BuildContext context) =>
      Localizations.of<UILocalizations>(context, UILocalizations) ?? const UILocalizations$Default();

  /// Get language by code.
  static ({String name, String nativeName})? getLanguageByCode(String code) => switch (_isoLangs[code]) {
    (String, String) lang => (name: lang.$1, nativeName: lang.$2),
    _ => null,
  };

  /// Get supported locales.
  static List<Locale> get supportedLocales => const <Locale>[Locale('en'), Locale('ru')];

  /// Returns the localized strings for the given [context].
  static T stringOf<T>(BuildContext context) => Localizations.of<T>(context, T)!;

  /// Returns the current locale of the [context].
  static Locale? localeOf(BuildContext context) => Localizations.localeOf(context);

  /// Loads the [locale].
  static Future<UILocalizations> load(Locale locale) => const _LocalizationView().load(locale);
}

/// English strings shipped with the package.
class UILocalizations$Default extends UILocalizations {
  /// Creates a default English localization.
  const UILocalizations$Default();

  @override
  String get language => 'English';

  @override
  String get loading => 'Loading';

  @override
  String get backButton => 'Back';

  @override
  String get closeButton => 'Close';

  @override
  String get doneButton => 'Done';

  @override
  String get moreLabel => 'more';

  @override
  String get actionNext => 'Next';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get selectLabel => 'Select';

  @override
  String get notNowButton => 'Not now';

  @override
  String get deleteButton => 'Delete';

  @override
  String get editButton => 'Change';

  @override
  String get actionTurnLeft => 'Turn left';

  @override
  String get actionTurnRight => 'Turn right';

  @override
  String get actionPhotoMake => 'Make a photo';

  @override
  String get actionPhotoSelectFromGallery => 'Select from gallery';

  @override
  String get labelCalendar => 'Calendar';

  @override
  String get labelDate => 'Date';

  @override
  String get labelDuration => 'Duration';

  @override
  String get labelGender => 'Gender';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get labelSettings => 'Settings';

  @override
  String get todayLabel => 'Today';

  @override
  String get textIsOnline => 'Online';

  @override
  String get textIsBlocked => 'Blocked';

  @override
  String get textGenderMale => 'Male';

  @override
  String get textGenderFemale => 'Female';

  @override
  String get textNoValue => 'No value';

  @override
  String get notSelectedLabelMasculine => 'Not selected';

  @override
  String get notSelectedLabelFeminine => 'Not selected';

  @override
  String get notSelectedLabelNeuter => 'Not selected';

  @override
  String get requestPermissionTitle => 'Allow access';

  @override
  String get requestPermissionPhotos =>
      'To be able to upload and update photos needs access to the gallery.\n\nPlease enable access in Device Settings > Privacy > Photos.';

  @override
  String get screenEditPhotoTitle => 'Photo editing';
}

/// Russian strings shipped with the package.
class UILocalizations$RU extends UILocalizations {
  /// Creates a Russian localization.
  const UILocalizations$RU();

  @override
  String get language => 'Русский';

  @override
  String get loading => 'Загрузка';

  @override
  String get backButton => 'Назад';

  @override
  String get closeButton => 'Закрыть';

  @override
  String get doneButton => 'Готово';

  @override
  String get moreLabel => 'ещё';

  @override
  String get actionNext => 'Далее';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get selectLabel => 'Выбрать';

  @override
  String get notNowButton => 'Не сейчас';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get editButton => 'Изменить';

  @override
  String get actionTurnLeft => 'Повернуть влево';

  @override
  String get actionTurnRight => 'Повернуть вправо';

  @override
  String get actionPhotoMake => 'Сделать фото';

  @override
  String get actionPhotoSelectFromGallery => 'Выбрать из галереи';

  @override
  String get labelCalendar => 'Календарь';

  @override
  String get labelDate => 'Дата';

  @override
  String get labelDuration => 'Длительность';

  @override
  String get labelGender => 'Пол';

  @override
  String get phoneLabel => 'Телефон';

  @override
  String get labelSettings => 'Настройки';

  @override
  String get todayLabel => 'Сегодня';

  @override
  String get textIsOnline => 'Онлайн';

  @override
  String get textIsBlocked => 'Заблокирован';

  @override
  String get textGenderMale => 'Мужской';

  @override
  String get textGenderFemale => 'Женский';

  @override
  String get textNoValue => 'Нет значения';

  @override
  String get notSelectedLabelMasculine => 'Не выбран';

  @override
  String get notSelectedLabelFeminine => 'Не выбрана';

  @override
  String get notSelectedLabelNeuter => 'Не выбрано';

  @override
  String get requestPermissionTitle => 'Разрешите доступ';

  @override
  String get requestPermissionPhotos =>
      'Чтобы Вы могли загружать и обновонлять фотографии, приложению нужен доступ к галерее.\n\nПожалуйста, включите доступ в настройках устройства > Конфиденциальность > Фотографии.';

  @override
  String get screenEditPhotoTitle => 'Редактирование фото';
}

final class _LocalizationView extends LocalizationsDelegate<UILocalizations> {
  const _LocalizationView();

  static const Set<String> _supported = <String>{'en', 'ru'};

  @override
  bool isSupported(Locale locale) => _supported.contains(locale.languageCode);

  @override
  Future<UILocalizations> load(Locale locale) => SynchronousFuture<UILocalizations>(
    UILocalizations._current = switch (locale.languageCode) {
      'ru' => const UILocalizations$RU(),
      _ => const UILocalizations$Default(),
    },
  );

  @override
  bool shouldReload(covariant _LocalizationView old) => false;
}

const Map<String, (String name, String nativeName)> _isoLangs = <String, (String name, String nativeName)>{
  'ab': ('Abkhaz', 'аҧсуа'),
  'aa': ('Afar', 'Afaraf'),
  'af': ('Afrikaans', 'Afrikaans'),
  'ak': ('Akan', 'Akan'),
  'sq': ('Albanian', 'Shqip'),
  'am': ('Amharic', 'አማርኛ'),
  'ar': ('Arabic', 'العربية'),
  'an': ('Aragonese', 'Aragonés'),
  'hy': ('Armenian', 'Հայերեն'),
  'as': ('Assamese', 'অসমীয়া'),
  'av': ('Avaric', 'авар мацӀ, магӀарул мацӀ'),
  'ae': ('Avestan', 'avesta'),
  'ay': ('Aymara', 'aymar aru'),
  'az': ('Azerbaijani', 'azərbaycan dili'),
  'bm': ('Bambara', 'bamanankan'),
  'ba': ('Bashkir', 'башҡорт теле'),
  'eu': ('Basque', 'euskara, euskera'),
  'be': ('Belarusian', 'Беларуская'),
  'bn': ('Bengali', 'বাংলা'),
  'bh': ('Bihari', 'भोजपुरी'),
  'bi': ('Bislama', 'Bislama'),
  'bs': ('Bosnian', 'bosanski jezik'),
  'br': ('Breton', 'brezhoneg'),
  'bg': ('Bulgarian', 'български език'),
  'my': ('Burmese', 'ဗမာစာ'),
  'ca': ('Catalan, Valencian', 'Català'),
  'ch': ('Chamorro', 'Chamoru'),
  'ce': ('Chechen', 'нохчийн мотт'),
  'ny': ('Chichewa, Chewa, Nyanja', 'chiCheŵa, chinyanja'),
  'zh': ('Chinese', '中文 (Zhōngwén), 汉语, 漢語'),
  'cv': ('Chuvash', 'чӑваш чӗлхи'),
  'kw': ('Cornish', 'Kernewek'),
  'co': ('Corsican', 'corsu, lingua corsa'),
  'cr': ('Cree', 'ᓀᐦᐃᔭᐍᐏᐣ'),
  'hr': ('Croatian', 'hrvatski'),
  'cs': ('Czech', 'česky, čeština'),
  'da': ('Danish', 'dansk'),
  'dv': ('Divehi, Dhivehi, Maldivian;', 'ދިވެހި'),
  'nl': ('Dutch', 'Nederlands, Vlaams'),
  'en': ('English', 'English'),
  'eo': ('Esperanto', 'Esperanto'),
  'et': ('Estonian', 'eesti, eesti keel'),
  'fo': ('Faroese', 'føroyskt'),
  'fj': ('Fijian', 'vosa Vakaviti'),
  'fi': ('Finnish', 'suomi, suomen kieli'),
  'fr': ('French', 'Français'),
  'ff': ('Fula, Fulah, Pulaar, Pular', 'Fulfulde, Pulaar, Pular'),
  'gl': ('Galician', 'Galego'),
  'ka': ('Georgian', 'ქართული'),
  'de': ('German', 'Deutsch'),
  'el': ('Greek, Modern', 'Ελληνικά'),
  'gn': ('Guaraní', 'Avañeẽ'),
  'gu': ('Gujarati', 'ગુજરાતી'),
  'ht': ('Haitian, Haitian Creole', 'Kreyòl ayisyen'),
  'ha': ('Hausa', 'Hausa, هَوُسَ'),
  'he': ('Hebrew (modern)', 'עברית'),
  'hz': ('Herero', 'Otjiherero'),
  'hi': ('Hindi', 'हिन्दी, हिंदी'),
  'ho': ('Hiri Motu', 'Hiri Motu'),
  'hu': ('Hungarian', 'Magyar'),
  'ia': ('Interlingua', 'Interlingua'),
  'id': ('Indonesian', 'Bahasa Indonesia'),
  'ie': ('Interlingue', 'Interlingue'),
  'ga': ('Irish', 'Gaeilge'),
  'ig': ('Igbo', 'Asụsụ Igbo'),
  'ik': ('Inupiaq', 'Iñupiaq, Iñupiatun'),
  'io': ('Ido', 'Ido'),
  'is': ('Icelandic', 'Íslenska'),
  'it': ('Italian', 'Italiano'),
  'iu': ('Inuktitut', 'ᐃᓄᒃᑎᑐᑦ'),
  'ja': ('Japanese', '日本語 (にほんご／にっぽんご)'),
  'jv': ('Javanese', 'basa Jawa'),
  'kl': ('Kalaallisut, Greenlandic', 'kalaallisut, kalaallit oqaasii'),
  'kn': ('Kannada', 'ಕನ್ನಡ'),
  'kr': ('Kanuri', 'Kanuri'),
  'kk': ('Kazakh', 'Қазақ тілі'),
  'km': ('Khmer', 'ភាសាខ្មែរ'),
  'ki': ('Kikuyu, Gikuyu', 'Gĩkũyũ'),
  'rw': ('Kinyarwanda', 'Ikinyarwanda'),
  'ky': ('Kirghiz, Kyrgyz', 'кыргыз тили'),
  'kv': ('Komi', 'коми кыв'),
  'kg': ('Kongo', 'KiKongo'),
  'ko': ('Korean', '한국어 (韓國語), 조선말 (朝鮮語)'),
  'kj': ('Kwanyama, Kuanyama', 'Kuanyama'),
  'la': ('Latin', 'latine, lingua latina'),
  'lb': ('Luxembourgish', 'Lëtzebuergesch'),
  'lg': ('Luganda', 'Luganda'),
  'li': ('Limburgish, Limburgan, Limburger', 'Limburgs'),
  'ln': ('Lingala', 'Lingála'),
  'lo': ('Lao', 'ພາສາລາວ'),
  'lt': ('Lithuanian', 'lietuvių kalba'),
  'lu': ('Luba-Katanga', ''),
  'lv': ('Latvian', 'latviešu valoda'),
  'gv': ('Manx', 'Gaelg, Gailck'),
  'mk': ('Macedonian', 'македонски јазик'),
  'mg': ('Malagasy', 'Malagasy fiteny'),
  'ml': ('Malayalam', 'മലയാളം'),
  'mt': ('Maltese', 'Malti'),
  'mi': ('Māori', 'te reo Māori'),
  'mr': ('Marathi (Marāṭhī)', 'मराठी'),
  'mh': ('Marshallese', 'Kajin M̧ajeļ'),
  'mn': ('Mongolian', 'монгол'),
  'na': ('Nauru', 'Ekakairũ Naoero'),
  'nb': ('Norwegian Bokmål', 'Norsk bokmål'),
  'nd': ('North Ndebele', 'isiNdebele'),
  'ne': ('Nepali', 'नेपाली'),
  'ng': ('Ndonga', 'Owambo'),
  'nn': ('Norwegian Nynorsk', 'Norsk nynorsk'),
  'no': ('Norwegian', 'Norsk'),
  'ii': ('Nuosu', 'ꆈꌠ꒿ Nuosuhxop'),
  'nr': ('South Ndebele', 'isiNdebele'),
  'oc': ('Occitan', 'Occitan'),
  'oj': ('Ojibwe, Ojibwa', 'ᐊᓂᔑᓈᐯᒧᐎᓐ'),
  'om': ('Oromo', 'Afaan Oromoo'),
  'or': ('Oriya', 'ଓଡ଼ିଆ'),
  'pi': ('Pāli', 'पाऴि'),
  'fa': ('Persian', 'فارسی'),
  'pl': ('Polish', 'Polski'),
  'ps': ('Pashto, Pushto', 'پښتو'),
  'pt': ('Portuguese', 'Português'),
  'qu': ('Quechua', 'Runa Simi, Kichwa'),
  'rm': ('Romansh', 'rumantsch grischun'),
  'rn': ('Kirundi', 'kiRundi'),
  'ro': ('Romanian, Moldavian, Moldovan', 'română'),
  'ru': ('Russian', 'Русский'),
  'sa': ('Sanskrit (Saṁskṛta)', 'संस्कृतम्'),
  'sc': ('Sardinian', 'sardu'),
  'se': ('Northern Sami', 'Davvisámegiella'),
  'sm': ('Samoan', 'gagana faa Samoa'),
  'sg': ('Sango', 'yângâ tî sängö'),
  'sr': ('Serbian', 'српски језик'),
  'gd': ('Scottish Gaelic, Gaelic', 'Gàidhlig'),
  'sn': ('Shona', 'chiShona'),
  'si': ('Sinhala, Sinhalese', 'සිංහල'),
  'sk': ('Slovak', 'slovenčina'),
  'sl': ('Slovene', 'slovenščina'),
  'so': ('Somali', 'Soomaaliga, af Soomaali'),
  'st': ('Southern Sotho', 'Sesotho'),
  'es': ('Spanish', 'Español'),
  'su': ('Sundanese', 'Basa Sunda'),
  'sw': ('Swahili', 'Kiswahili'),
  'ss': ('Swati', 'SiSwati'),
  'sv': ('Swedish', 'svenska'),
  'ta': ('Tamil', 'தமிழ்'),
  'te': ('Telugu', 'తెలుగు'),
  'th': ('Thai', 'ไทย'),
  'ti': ('Tigrinya', 'ትግርኛ'),
  'bo': ('Tibetan', 'བོད་ཡིག'),
  'tk': ('Turkmen', 'Türkmen, Түркмен'),
  'tn': ('Tswana', 'Setswana'),
  'to': ('Tonga (Tonga Islands)', 'faka Tonga'),
  'tr': ('Turkish', 'Türkçe'),
  'ts': ('Tsonga', 'Xitsonga'),
  'tw': ('Twi', 'Twi'),
  'ty': ('Tahitian', 'Reo Tahiti'),
  'uk': ('Ukrainian', 'українська'),
  'ur': ('Urdu', 'اردو'),
  've': ('Venda', 'Tshivenḓa'),
  'vi': ('Vietnamese', 'Tiếng Việt'),
  'vo': ('Volapük', 'Volapük'),
  'wa': ('Walloon', 'Walon'),
  'cy': ('Welsh', 'Cymraeg'),
  'wo': ('Wolof', 'Wollof'),
  'fy': ('Western Frisian', 'Frysk'),
  'xh': ('Xhosa', 'isiXhosa'),
  'yi': ('Yiddish', 'ייִדיש'),
  'yo': ('Yoruba', 'Yorùbá'),
};
