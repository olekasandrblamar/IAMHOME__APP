import 'package:flutter/material.dart';

enum LanguageSelectionChoice {
  en,
  ar,
  zh,
  nl,
  fr,
  de,
  el,
  hi,
  it,
  ja,
  ko,
  ms,
  pt,
  ru,
  es,
  sv,
  tr,
  th,
  vi
}

final List<Locale> SupportedLocals = [
  const Locale('en', 'US'),
  const Locale('hi', 'IN'),
  const Locale('ar', 'AE'),
  const Locale('zh', 'CN'),
  const Locale('nl', 'NL'),
  const Locale('fr', 'FR'),
  const Locale('de', 'DE'),
  const Locale('el', 'GR'),
  const Locale('hi', 'IN'),
  const Locale('it', 'IT'),
  const Locale('ja', 'JP'),
  const Locale('ko', 'KR'),
  const Locale('ms', 'MY'),
  const Locale('pt', 'PT'),
  const Locale('ru', 'RU'),
  const Locale('es', 'ES'),
  const Locale('sv', 'SE'),
  const Locale('tr', 'TR'),
  const Locale('th', 'TH'),
  const Locale('vi', 'VN'),
];

final List<dynamic> LANGUAGES_DATA = [
  {
    'language_code': 'en',
    'label': 'English (US)',
    'language': 'English',
    'countryCode': 'US',
    'value': LanguageSelectionChoice.en
  },
  {
    'language_code': 'ar',
    'label': 'Arabic',
    'language': 'عربى',
    'countryCode': 'AE',
    'value': LanguageSelectionChoice.ar
  },
  {
    'language_code': 'zh',
    'label': 'Chinese',
    'language': '中文',
    'countryCode': 'CN',
    'value': LanguageSelectionChoice.zh
  },
  {
    'language_code': 'nl',
    'label': 'Dutch',
    'language': 'Nederlands',
    'countryCode': 'NL',
    'value': LanguageSelectionChoice.nl
  },
  {
    'language_code': 'fr',
    'label': 'French',
    'language': 'Français',
    'countryCode': 'FR',
    'value': LanguageSelectionChoice.fr
  },
  {
    'language_code': 'de',
    'label': 'German',
    'language': 'Deutsche',
    'countryCode': 'DE',
    'value': LanguageSelectionChoice.de
  },
  {
    'language_code': 'el',
    'label': 'Greek',
    'language': 'Ελληνικά',
    'countryCode': 'GR',
    'value': LanguageSelectionChoice.el
  },
  {
    'language_code': 'hi',
    'language': 'हिंदी',
    'label': 'Hindi',
    'countryCode': 'IN',
    'value': LanguageSelectionChoice.hi
  },
  {
    'language_code': 'it',
    'label': 'Italian',
    'language': 'Italiano',
    'countryCode': 'IT',
    'value': LanguageSelectionChoice.it
  },
  {
    'language_code': 'ja',
    'label': 'Japanese',
    'language': '日本人',
    'countryCode': 'JP',
    'value': LanguageSelectionChoice.ja
  },
  {
    'language_code': 'ko',
    'label': 'Korean',
    'language': '한국어',
    'countryCode': 'KR',
    'value': LanguageSelectionChoice.ko
  },
  {
    'language_code': 'ms',
    'label': 'Malaysian',
    'language': 'Orang Malaysia',
    'countryCode': 'MY',
    'value': LanguageSelectionChoice.ms
  },
  {
    'language_code': 'pt',
    'label': 'Portuguese',
    'language': 'Português',
    'countryCode': 'PT',
    'value': LanguageSelectionChoice.pt
  },
  {
    'language_code': 'ru',
    'label': 'Russian',
    'language': 'русский',
    'countryCode': 'RU',
    'value': LanguageSelectionChoice.ru
  },
  {
    'language_code': 'es',
    'label': 'Spanish',
    'language': 'Español',
    'countryCode': 'ES',
    'value': LanguageSelectionChoice.es
  },
  {
    'language_code': 'sv',
    'label': 'Swedish',
    'language': 'svenska',
    'countryCode': 'SE',
    'value': LanguageSelectionChoice.sv
  },
  {
    'language_code': 'tr',
    'label': 'Turkish',
    'language': 'Türk',
    'countryCode': 'TR',
    'value': LanguageSelectionChoice.tr
  },
  {
    'language_code': 'th',
    'label': 'Thai',
    'language': 'ไทย',
    'countryCode': 'TH',
    'value': LanguageSelectionChoice.th
  },
  {
    'language_code': 'vi',
    'label': 'Vietnamese',
    'language': 'Tiếng Việt',
    'countryCode': 'VN',
    'value': LanguageSelectionChoice.vi
  },
];
