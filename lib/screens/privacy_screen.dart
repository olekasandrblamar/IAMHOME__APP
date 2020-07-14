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
      // appBar: AppBar(
      //   title: Text('Home'),
      // ),
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Container(
                  margin: EdgeInsets.only(bottom: 20),
                  // width: double.infinity,
                  // height: 80,
                  child: Image(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/ceraswithletter.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Our Terms and Conditions',
                textAlign: TextAlign.center,
                style: AppTheme.title,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              Text(
                'Before using the Ceras app, please read the following terms carefully.  Click the title for details',
                textAlign: TextAlign.start,
                style: AppTheme.subtitle,
              ),
              SizedBox(
                height: 50,
              ),
              InkWell(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'End User License Agreement',
                    style: AppTheme.title,
                    textAlign: TextAlign.left,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                onTap: () => _openBrowser(),
              ),
              SizedBox(
                height: 30,
              ),
              InkWell(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Privacy Policy',
                    style: AppTheme.title,
                    textAlign: TextAlign.left,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                onTap: () => _openBrowser(),
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
                color: Color(0XFF6C63FF),
                textColor: Colors.white,
                child: Text('Agree'),
                onPressed: () {
                  return Navigator.of(context).pushReplacementNamed(
                    routes.NotificationsRoute,
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
