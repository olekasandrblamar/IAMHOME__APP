import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;

class PrivacyScreen extends StatelessWidget {
  void _openBrowser() {
    final browser = ChromeSafariBrowser();
    browser.open(
      url: 'https://flutter.io',
      options: ChromeSafariBrowserClassOptions(
        android: AndroidChromeCustomTabsOptions(
          addDefaultShareMenuItem: false,
        ),
        ios: IOSSafariOptions(
          barCollapsingEnabled: true,
          entersReaderIfAvailable: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: true,
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
                  'Our Terms and Conditions',
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
                  'Before using the Ceras app, please read the following terms carefully. \n\n Agree to End User License Agreement & Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: AppTheme.subtitle,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 150,
                    height: 75,
                    padding: EdgeInsets.all(10),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.5),
                      ),
                      color: Color(0XFFE6E6E6),
                      textColor: Colors.black,
                      child: Text(
                        'View',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _openBrowser(),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 75,
                    padding: EdgeInsets.all(10),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.5),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text(
                        'Agree',
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
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
