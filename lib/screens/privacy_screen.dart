import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/widgets/translateheader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ceras/theme.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

class PrivacyScreen extends StatelessWidget {
  void _openBrowser() {
    final browser = InAppBrowser();
    browser.openFile(
      // url: 'https://flutter.io',
      assetFilePath: "assets/privacy/index.html",
      // options: InAppBrowserClassOptions(
      // inAppWebViewGroupOptions: InAppWebViewGroupOptions(
      // crossPlatform: InAppWebViewOptions(
      // useShouldOverrideUrlLoading: true,
      // useOnLoadResource: true,
      // transparentBackground: true,
      // applicationNameForUserAgent: 'Ceras',
      // ),
      // ),
      // ),
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
                    _appLocalization.translate('privacy.description1') +
                        '\n\n' +
                        _appLocalization.translate('privacy.description2'),
                    textAlign: TextAlign.center,
                    style: AppTheme.subtitle,
                  ),
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
                    onPressed: () {
                      return Navigator.of(context).pushReplacementNamed(
                        routes.NotificationsRoute,
                      );
                    },
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
