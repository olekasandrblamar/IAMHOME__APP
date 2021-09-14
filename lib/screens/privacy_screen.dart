import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/widgets/translateheader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ceras/theme.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

class PrivacyScreen extends StatefulWidget {
  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  Map<String, bool> terms = {
    'term1': false,
    'term2': false,
    'term3': false,
  };

  void _agree() {
    bool checkAll = true;
    terms.forEach(
      (k, v) => {
        if (!v) {checkAll = false}
      },
    );

    if (checkAll) {
      Navigator.of(context).pushReplacementNamed(
        routes.NotificationsRoute,
      );
    } else {
      _showDialog();
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Missing Fields!',
          ),
          content: Text(
            'Please verify all details.',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Okay',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openBrowser() {
    final browser = InAppBrowser();
    browser.openFile(
      assetFilePath: "assets/privacy/index.html",
      options: InAppBrowserClassOptions(
        crossPlatform: InAppBrowserOptions(
          toolbarTopBackgroundColor: Colors.white,
          hideUrlBar: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: translateHeader(context),
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 300.0,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: FadeInImage(
                    placeholder: AssetImage(
                      'assets/images/placeholder.jpg',
                    ),
                    image: AssetImage(
                      'assets/images/t&c.png',
                    ),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeInCurve: Curves.easeIn,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    _appLocalization.translate('privacy.title'),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTheme.title,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    // vertical: 5.0,
                    horizontal: 35.0,
                  ),
                  child: Text(
                    _appLocalization.translate('privacy.description1'),
                    textAlign: TextAlign.center,
                    style: AppTheme.subtitle,
                  ),
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text('To call 911 in case of emergency.'),
                  value: terms['term1'],
                  onChanged: (bool value) {
                    print(value);
                    setState(() {
                      terms['term1'] = value;
                    });
                  },
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'There can be a delay in the data transmission from my device for reasons beyond Ceras Health control impacting the timely response from my care team including Ceras Health.',
                  ),
                  value: terms['term2'],
                  onChanged: (bool value) {
                    setState(() {
                      terms['term2'] = value;
                    });
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'The wearable device provided to me at times can malfunction for reasons beyond Ceras Health control. If such an event occurs, I shall contact Ceras immediately.',
                  ),
                  value: terms['term3'],
                  onChanged: (bool value) {
                    setState(() {
                      terms['term3'] = value;
                    });
                  },
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  width: 180,
                  height: 75,
                  padding: EdgeInsets.all(10),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.5),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      _appLocalization.translate('privacy.buttons.agree'),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () => _agree(),
                  ),
                ),
                Container(
                  width: 180,
                  height: 75,
                  padding: EdgeInsets.all(10),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.5),
                    ),
                    color: Color(0XFFE6E6E6),
                    textColor: Colors.black,
                    child: Text(
                      _appLocalization.translate('privacy.buttons.view'),
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () => _openBrowser(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
