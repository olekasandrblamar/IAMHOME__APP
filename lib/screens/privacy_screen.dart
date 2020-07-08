import 'package:flutter/material.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;

class PrivacyScreen extends StatelessWidget {
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
                  width: double.infinity,
                  height: 100,
                  child: Image(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/ceraswithletter.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              FittedBox(
                child: Text(
                  'Our Terms and Conditions',
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
                'Before using the Ceras app, please read the following terms carefully.  Click the title for details',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'End User License Agreement',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.left,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.left,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.0,
                      color: Colors.black,
                    ),
                  ),
                ),
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
            child: Text('Agree'),
            onPressed: () {
              return Navigator.of(context).pushReplacementNamed(
                routes.NotificationsRoute,
              );
            },
          ),
        ),
      ),
    );
  }
}
