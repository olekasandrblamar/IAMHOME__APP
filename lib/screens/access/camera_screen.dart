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
    Permission.camera.request();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(children: [
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          Expanded(
            child: Center(child: Text('')),
          )
        ]),
        actions: <Widget>[
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.headset_mic),
            onPressed: () {},
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              FittedBox(
                child: Text(
                  'Camera',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'To better connect with you, the care plan you select require us to send you the notifications.  Join the wellness tracker program so Ceras can continue to update your activities',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(
                height: 20,
              ),
              FittedBox(
                child: Text(
                  'About Camera',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
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
              child: Text('Next'),
              onPressed: () {
                return Navigator.of(context).pushReplacementNamed(
                  routes.SetupHomeRoute,
                );
              }),
        ),
      ),
    );
  }
}
