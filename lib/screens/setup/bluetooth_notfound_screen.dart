import 'package:flutter/material.dart';
import 'package:ceras/theme.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

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
      body: Container(
        width: double.infinity,
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
                        'assets/images/bluetooth.png',
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
                      color: Theme.of(context).primaryColor,
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
