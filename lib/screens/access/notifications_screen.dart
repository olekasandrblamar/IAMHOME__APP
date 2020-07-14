import 'package:flutter/material.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied!'),
          content: Text('Do you want to open settings'),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Open'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkPermission() async {
    final status = await Permission.notification.request();

    if (PermissionStatus.granted == status) {
      _goToLocations();
    } else {
      _showDialog();
    }
  }

  dynamic _goToLocations() {
    return Navigator.of(context).pushReplacementNamed(
      routes.LocationsRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: true,
        child: Container(
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
                    'assets/images/push_notification.png',
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
                  'Push Notification',
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
                  'To better connect with you, the care plan you select require us to send you the notifications. Join the wellness tracker program so Ceras can continue to update your activites.',
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
                      onPressed: () => _goToLocations(),
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
                      onPressed: () => _checkPermission(),
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
