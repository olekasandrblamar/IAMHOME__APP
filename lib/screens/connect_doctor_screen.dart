import 'package:flutter/material.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;

class ConnectDoctorScreen extends StatelessWidget {
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
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 20),
                width: double.infinity,
                height: 300,
                child: Image(
                  // fit: BoxFit.fill,
                  image: AssetImage('assets/images/4.png'),
                ),
              ),
              FittedBox(
                child: Text(
                  'CONNECT TO DOCTOR',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Container(),
                    flex: 2,
                  ),
                  Flexible(
                    child: Container(
                      // margin: EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                        ),
                        decoration: InputDecoration(
                          // border: OutlineInputBorder(),
                          // labelText: 'Phone',
                          hintText: "-   -   -   -",
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        // inputFormatters: [_otpMaskFormatter],
                        autofocus: true,
                      ),
                    ),
                    flex: 4,
                  ),
                  Flexible(
                    child: Container(),
                    flex: 2,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Enter the invite code.',
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
                'Call member support for invite code \n1-877-300-1232',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
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
              child: Text('Connect'),
              onPressed: () {
                return Navigator.of(context).pushReplacementNamed(
                  routes.HomeRoute,
                );
              }),
        ),
      ),
    );
  }
}
