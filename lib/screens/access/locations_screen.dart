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

  void _checkDevice(context) {
    if (Platform.isIOS) {
      _checkPermission(context);
    } else {
      _showDialog(context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('Got state ${state}');
    switch (state) {
      case AppLifecycleState.resumed:
        await _checkAndGoNext();
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

  void _showDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm',
          ),
          content: Text(
            'The Ceras app collects location data to enable your doctor and care team to provide real time health care intervention in the case of emergency even when the app is closed or not in use.',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Ok',
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _checkPermission(context);
              },
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

    if (PermissionStatus.granted == status) {
      _goToCamera(context);
    } else {
      showAccessAlertDialog(context);
    }
  }

  dynamic _goToCamera(context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('walthrough', false);

    return Navigator.of(context).pushReplacementNamed(
      routes.SetupHomeRoute,
    );
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
