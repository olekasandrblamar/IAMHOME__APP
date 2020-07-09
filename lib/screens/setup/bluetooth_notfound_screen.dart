import 'package:flutter/material.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';

class BluetoothNotfoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 5.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
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
                        'assets/images/Group2.png',
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
                      'Turn on Bluetooth',
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
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Turn Bluetooth on your smartphone.',
                      textAlign: TextAlign.center,
                      style: AppTheme.subtitle,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    width: 200,
                    height: 75,
                    padding: EdgeInsets.all(10),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.5),
                      ),
                      color: Color(0XFF6C63FF),
                      textColor: Colors.white,
                      child: Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        return Navigator.of(context).pushReplacementNamed(
                          routes.SetupHomeRoute,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
