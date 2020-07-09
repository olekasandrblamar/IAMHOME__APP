import 'package:flutter/material.dart';
import 'package:lifeplus/screens/setup/setup_active_screen.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';

class SetupConnectScreen extends StatelessWidget {

  Future<bool> _connectDevice() async{
    //Capture the device last 4
    //Add code to call native methods to connect

  }

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
        child: SingleChildScrollView(
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
                    'assets/images/2.png',
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
                        keyboardType: TextInputType.text,
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
              SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: FittedBox(
                  child: Text(
                    'Enter last 4 characters of device ID',
                    textAlign: TextAlign.center,
                    style: AppTheme.title,
                  ),
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     // vertical: 5.0,
              //     horizontal: 35.0,
              //   ),
              //
              //   child: Text(
              //     'Last connected 04/24/2020  12:35 PM.',
              //     textAlign: TextAlign.center,
              //     style: AppTheme.subtitle,
              //   ),
              // ),
              SizedBox(
                height: 25,
              ),
              Container(
                width: 150,
                height: 75,
                padding: EdgeInsets.all(10),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.5),
                  ),
                  color: Color(0XFF6C63FF),
                  textColor: Colors.white,
                  child: Text(
                    'Connect',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () {

                    return Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              SetupActiveScreen(),
                          settings: const RouteSettings(
                              name: routes.SetupActiveRoute),
                        ),
                        (Route<dynamic> route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
