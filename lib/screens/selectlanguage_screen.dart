import 'package:ceras/data/language_data.dart';
import 'package:flutter/material.dart';
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/providers/applanguage_provider.dart';
import 'package:provider/provider.dart';

import 'package:ceras/theme.dart';
import 'package:ceras/constants/route_paths.dart' as routes;

class SelectLanguageScreen extends StatefulWidget {
  @override
  _SelectLanguageScreenState createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
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
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   // elevation: 0,
      //   title: Image.asset(
      //     'assets/images/ceraswithletter.png',
      //     fit: BoxFit.contain,
      //     height: 50,
      //   ),
      // ),
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: true,
        child: Container(
          // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 25,
                ),
                child: Text(
                  _appLocalization.translate('appLanguage.page.title'),
                  style: AppTheme.title,
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: _languages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        elevation: 0,
                        color: _language == _languages[index]['value']
                            ? Theme.of(context).primaryColor
                            : Color(0xffd5d5d6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: GridTile(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    // color: Colors.black.withOpacity(0.7),
                                    height: 30,
                                    width: double.infinity,
                                    child: Center(
                                      child: FittedBox(
                                        child: Text(
                                          _languages[index]['language'],
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: _language ==
                                                    _languages[index]['value']
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            fontFamily: 'Regular',
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            _appLanguage.changeLanguage(
                              Locale(_languages[index]['language_code']),
                            );

                            setState(() {
                              _language = _languages[index]['value'];
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200,
              height: 90,
              padding: EdgeInsets.all(20),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.5),
                ),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text(
                  _appLocalization.translate('appLanguage.buttons.next'),
                ),
                onPressed: () {
                  return Navigator.of(context).pushReplacementNamed(
                    routes.PrivacyRoute,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
