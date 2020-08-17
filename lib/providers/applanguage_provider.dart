import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageProvider extends ChangeNotifier {
  Locale _appLocale = Locale('en');

  Locale get appLocal => _appLocale ?? Locale("en");

  final List<dynamic> _languages = [
    {
      'language_code': 'en',
      'label': 'English',
      'countryCode': 'US',
    },
    {
      'language_code': 'ar',
      'label': 'Arabic',
      'countryCode': 'AE',
    },
    {
      'language_code': 'zh',
      'label': 'Chinese',
      'countryCode': 'CN',
    },
    {
      'language_code': 'nl',
      'label': 'Dutch',
      'countryCode': 'NL',
    },
    {
      'language_code': 'fr',
      'label': 'French',
      'countryCode': 'FR',
    },
    {
      'language_code': 'de',
      'label': 'German',
      'countryCode': 'DE',
    },
    {
      'language_code': 'el',
      'label': 'Greek',
      'countryCode': 'GR',
    },
    {
      'language_code': 'hi',
      'label': 'Hindi',
      'countryCode': 'IN',
    },
    {
      'language_code': 'it',
      'label': 'Italian',
      'countryCode': 'IT',
    },
    {
      'language_code': 'ja',
      'label': 'Japanese',
      'countryCode': 'JP',
    },
    {
      'language_code': 'ko',
      'label': 'Korean',
      'countryCode': 'KR',
    },
    {
      'language_code': 'ms',
      'label': 'Malaysian',
      'countryCode': 'MY',
    },
    {
      'language_code': 'pt',
      'label': 'Portuguese',
      'countryCode': 'PT',
    },
    {
      'language_code': 'ru',
      'label': 'Russian',
      'countryCode': 'RU',
    },
    {
      'language_code': 'es',
      'label': 'Spanish',
      'countryCode': 'ES',
    },
    {
      'language_code': 'sv',
      'label': 'Swedish',
      'countryCode': 'SE',
    },
    {
      'language_code': 'tr',
      'label': 'Turkish',
      'countryCode': 'TR',
    },
    {
      'language_code': 'th',
      'label': 'Thai',
      'countryCode': 'TH',
    },
    {
      'language_code': 'vi',
      'label': 'Vietnamese',
      'countryCode': 'VN',
    },
  ];

  fetchLangCode() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      return 'en';
    }
    // print(prefs.getString('language_code'));
    return prefs.getString('language_code');
  }

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('en');
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code'));
    notifyListeners();
    return Null;
  }

  void changeLanguage(Locale type) async {
    _changeLanguage(type);
    notifyListeners();
  }

  void changeLanguagePage(Locale type) async {
    _changeLanguage(type);
  }

  void _changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }

    final languageIndex =
        _languages.indexWhere((x) => type == Locale(x['language_code']));

    if (languageIndex >= 0) {
      _appLocale = type;

      await prefs.setString(
        'language_code',
        _languages[languageIndex]['language_code'],
      );

      await prefs.setString(
        'countryCode',
        _languages[languageIndex]['countryCode'],
      );
    } else {
      _appLocale = Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    }
  }
}
