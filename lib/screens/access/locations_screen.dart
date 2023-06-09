import 'dart:io';

import 'package:ceras/widgets/translateheader_widget.dart';
import 'package:flutter/material.dart';
import 'package:ceras/data/access_data.dart';
import 'package:ceras/models/access_model.dart';
import 'package:ceras/screens/access/widgets/access_widget.dart';
import 'package:ceras/theme.dart';

import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/show_access_alert_dialog.dart';

class LocationsScreen extends StatefulWidget {
  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void _checkDevice(context) {
    if (Platform.isIOS) {
      _checkPermission(context);
    } else {
      _showDialog(context, false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('Got state ${state}');
    switch (state) {
      case AppLifecycleState.resumed:
        _checkAndGoNext();
        break;
      case AppLifecycleState.inactive:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.paused:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.detached:
        // TODO: Handle this case.
        break;
    }
  }

  void _checkAndGoNext() async {
    if (Platform.isAndroid) {
      var alwaysStatus =
          (await Permission.locationAlways.status) == PermissionStatus.granted;
      var inUseStatus = (await Permission.locationWhenInUse.status) ==
          PermissionStatus.granted;
      var locationStatus =
          (await Permission.location.status) == PermissionStatus.granted;
      print(
          'Checking and going forward ${alwaysStatus} ${inUseStatus} ${locationStatus}');
      //if any of the permission is granted move to the next screen automatically
      if (locationStatus || inUseStatus || alwaysStatus) {
        await _goToCamera(context);
      }
    }
  }

  void _showDialog(context, bool skip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm',
          ),
          content: Container(
            height: 200,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              children: [
                Text('By turning the location on, you understand:'),
                SizedBox(
                  height: 5,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child: Text(
                      '\u25C9 As long as the Ceras app is in use, or in the background the Ceras app is able to continually receive the health data from your Ceras device ensuring that up to date information is transmitted to our platform for your doctor’s user 24x7.'),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();

                if (skip) {
                  _goToCamera(context);
                } else {
                  _checkPermission(context);
                }
              },
              child: Text(
                'Ok',
              ),
            ),
          ],
        );
      },
    );
  }

  void _checkPermission(context) async {
    var status = Platform.isIOS
        ? await Permission.location.request()
        : await Permission.locationAlways.request();

    // if (PermissionStatus.granted == status) {
    //   _goToCamera(context);
    // } else {
    //   showAccessAlertDialog(context);
    // }

    _goToCamera(context);
  }

  dynamic _goToCamera(context) async {
    if (Platform.isAndroid) {
      return Navigator.of(context).pushReplacementNamed(
        routes.StorageRoute,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('walthrough', false);

      return Navigator.of(context).pushReplacementNamed(
        routes.SetupHomeRoute,
      );
    }
  }

  final AccessModel locationData = ACCESS_DATA[1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: translateHeader(context),
      backgroundColor: AppTheme.white,
      body: AccessWidget(
        type: 'locations',
        accessData: locationData,
        onNothingSelected: () => _goToCamera(context),
        onPermissionSelected: () => _checkDevice(context),
      ),
    );
  }
}
