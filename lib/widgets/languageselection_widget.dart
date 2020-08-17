import 'package:flutter/material.dart';
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/providers/applanguage_provider.dart';
import 'package:provider/provider.dart';

import 'package:ceras/theme.dart';

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

class LanguageSelection extends StatefulWidget {
  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  LanguageSelectionChoice _language = LanguageSelectionChoice.en;

  final List<dynamic> _languages = [
    {
      'language_code': 'en',
      'label': 'English',
      'countryCode': 'US',
      'value': LanguageSelectionChoice.en
    },
    {
      'language_code': 'ar',
      'label': 'Arabic',
      'countryCode': 'AE',
      'value': LanguageSelectionChoice.ar
    },
    {
      'language_code': 'zh',
      'label': 'Chinese',
      'countryCode': 'CN',
      'value': LanguageSelectionChoice.zh
    },
    {
      'language_code': 'nl',
      'label': 'Dutch',
      'countryCode': 'NL',
      'value': LanguageSelectionChoice.nl
    },
    {
      'language_code': 'fr',
      'label': 'French',
      'countryCode': 'FR',
      'value': LanguageSelectionChoice.fr
    },
    {
      'language_code': 'de',
      'label': 'German',
      'countryCode': 'DE',
      'value': LanguageSelectionChoice.de
    },
    {
      'language_code': 'el',
      'label': 'Greek',
      'countryCode': 'GR',
      'value': LanguageSelectionChoice.el
    },
    {
      'language_code': 'hi',
      'label': 'Hindi',
      'countryCode': 'IN',
      'value': LanguageSelectionChoice.hi
    },
    {
      'language_code': 'it',
      'label': 'Italian',
      'countryCode': 'IT',
      'value': LanguageSelectionChoice.it
    },
    {
      'language_code': 'ja',
      'label': 'Japanese',
      'countryCode': 'JP',
      'value': LanguageSelectionChoice.ja
    },
    {
      'language_code': 'ko',
      'label': 'Korean',
      'countryCode': 'KR',
      'value': LanguageSelectionChoice.ko
    },
    {
      'language_code': 'ms',
      'label': 'Malaysian',
      'countryCode': 'MY',
      'value': LanguageSelectionChoice.ms
    },
    {
      'language_code': 'pt',
      'label': 'Portuguese',
      'countryCode': 'PT',
      'value': LanguageSelectionChoice.pt
    },
    {
      'language_code': 'ru',
      'label': 'Russian',
      'countryCode': 'RU',
      'value': LanguageSelectionChoice.ru
    },
    {
      'language_code': 'es',
      'label': 'Spanish',
      'countryCode': 'ES',
      'value': LanguageSelectionChoice.es
    },
    {
      'language_code': 'sv',
      'label': 'Swedish',
      'countryCode': 'SE',
      'value': LanguageSelectionChoice.sv
    },
    {
      'language_code': 'tr',
      'label': 'Turkish',
      'countryCode': 'TR',
      'value': LanguageSelectionChoice.tr
    },
    {
      'language_code': 'th',
      'label': 'Thai',
      'countryCode': 'TH',
      'value': LanguageSelectionChoice.th
    },
    {
      'language_code': 'vi',
      'label': 'Vietnamese',
      'countryCode': 'VN',
      'value': LanguageSelectionChoice.vi
    },
  ];

  @override
  void initState() {
    _loadSelectedLanguage();

    // TODO: implement initState
    super.initState();
  }

  void _loadSelectedLanguage() async {
    final appLang =
        await Provider.of<AppLanguageProvider>(context, listen: false)
            .fetchLangCode();

    final selectedLang = LanguageSelectionChoice.values.firstWhere(
      (e) => e.toString() == 'LanguageSelectionChoice.$appLang',
    );

    setState(
      () {
        _language = selectedLang;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _appLanguage = Provider.of<AppLanguageProvider>(context);
    final _appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appLocalization.translate('appLanguage.title'),
        ),
      ),
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            children: List.generate(
              _languages.length,
              (index) => Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Card(
                  child: RadioListTile<LanguageSelectionChoice>(
                    title: Text(_languages[index]['label']),
                    subtitle: Text(_languages[index]['label']),
                    value: _languages[index]['value'],
                    groupValue: _language,
                    onChanged: (LanguageSelectionChoice value) {
                      _appLanguage.changeLanguage(
                        Locale(_languages[index]['language_code']),
                      );
                      setState(() {
                        _language = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            // child: Column(
            //   children: <Widget>[
            //     Container(
            //       margin: EdgeInsets.only(bottom: 5),
            //       child: Card(
            //         child: RadioListTile<LanguageSelectionChoice>(
            //           title: const Text('English'),
            //           subtitle: const Text('English (US)'),
            //           value: LanguageSelectionChoice.en,
            //           groupValue: _language,
            //           onChanged: (LanguageSelectionChoice value) {
            //             _appLanguage.changeLanguage(Locale("en"));
            //             setState(() {
            //               _language = value;
            //             });
            //           },
            //         ),
            //       ),
            //     ),
            //     // Divider(),
            //     Container(
            //       margin: EdgeInsets.only(bottom: 5),
            //       child: Card(
            //         child: RadioListTile<LanguageSelectionChoice>(
            //           title: const Text('हिंदी'),
            //           subtitle: const Text('Hindi'),
            //           value: LanguageSelectionChoice.hi,
            //           groupValue: _language,
            //           onChanged: (LanguageSelectionChoice value) {
            //             _appLanguage.changeLanguage(Locale("hi"));
            //             setState(() {
            //               _language = value;
            //             });
            //           },
            //         ),
            //       ),
            //     ),
            //   ],
          ),
        ),
      ),
    );
  }
}
