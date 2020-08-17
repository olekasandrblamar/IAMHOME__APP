import 'package:ceras/data/language_data.dart';
import 'package:flutter/material.dart';
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/providers/applanguage_provider.dart';
import 'package:provider/provider.dart';

import 'package:ceras/theme.dart';

class LanguageSelection extends StatefulWidget {
  @override
  _LanguageSelectionState createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  LanguageSelectionChoice _language = LanguageSelectionChoice.en;

  final List<dynamic> _languages = LANGUAGES_DATA;

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
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Column(
            children: List.generate(
              _languages.length,
              (index) => Container(
                // margin: EdgeInsets.only(bottom: 5),
                // child: Card(
                child: RadioListTile<LanguageSelectionChoice>(
                  title: Row(
                    children: [
                      Text(
                        _languages[index]['language'] + ' - ',
                      ),
                      Text(
                        _languages[index]['label'],
                        style: TextStyle(
                          color: Color(0xFF797979),
                        ),
                      ),
                    ],
                  ),
                  // subtitle: Text(_languages[index]['label']),
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
                  // ),
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
