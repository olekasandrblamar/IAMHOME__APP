import 'package:ceras/widgets/translateheader_widget.dart';
import 'package:flutter/material.dart';
import 'package:ceras/data/access_data.dart';
import 'package:ceras/models/access_model.dart';
import 'package:ceras/screens/access/widgets/access_widget.dart';
import 'package:ceras/theme.dart';

import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';

import 'widgets/show_access_alert_dialog.dart';

class NotificationsScreen extends StatelessWidget {
  void _checkPermission(context) async {
    final status = await Permission.notification.request();

    if (PermissionStatus.granted == status) {
      _goToLocations(context);
    } else {
      showAccessAlertDialog(context);
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
            'By turning notifications on, the Ceras app on your phone is able to continually receive data from your Ceras device insuring that up to date information is sent securely to our platform where your doctor can access it 24/7.',
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
                _goToLocations(context);
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

  dynamic _goToLocations(context) {
    return Navigator.of(context).pushReplacementNamed(
      routes.LocationsRoute,
    );
  }

  final AccessModel locationData = ACCESS_DATA[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: translateHeader(context),
      backgroundColor: AppTheme.white,
      body: AccessWidget(
        type: 'notifications',
        accessData: locationData,
        onNothingSelected: () => _showDialog(context),
        onPermissionSelected: () => _checkPermission(context),
      ),
    );
  }
}
