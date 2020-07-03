import 'package:flutter/material.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Home'),
      // ),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 20),
                width: double.infinity,
                height: 300,
                child: Image(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/1.png'),
                ),
              ),
              FittedBox(
                child: Text(
                  'Stay Connected',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              Text(
                'Thank you for downloading ceras health app. Enhance your connected experience in 3 simple steps.',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.start,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
              ),
              Text(
                'Connect the device to capture welness information.',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text('Continue'),
              onPressed: () {
                return Navigator.of(context).pushReplacementNamed(
                  routes.ConnectDeviceRoute,
                );
              }),
        ),
      ),
    );
  }
}
