import 'package:flutter/material.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    // Permission.camera.request();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: true,
        child: Container(
          width: double.infinity,
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
                    'assets/images/camera.png',
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
                  'Camera',
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
                  'To better connect with you, the care plan you select require us to send you the notifications. Join the wellness tracker program so Ceras can continue to update your activities.',
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
                        'No, Thanks',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () {
                        return Navigator.of(context).pushReplacementNamed(
                          routes.PrivacyRoute,
                        );
                      },
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
                      color: Color(0XFF6C63FF),
                      textColor: Colors.white,
                      child: Text(
                        'I\'m In',
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
