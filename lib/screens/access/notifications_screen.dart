import 'package:flutter/material.dart';
import 'package:lifeplus/data/access_data.dart';
import 'package:lifeplus/models/access_model.dart';
import 'package:lifeplus/screens/access/widgets/access_widget.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;
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

  dynamic _goToLocations(context) {
    return Navigator.of(context).pushReplacementNamed(
      routes.LocationsRoute,
    );
  }

  final AccessModel locationData = ACCESS_DATA[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: AccessWidget(
        accessData: locationData,
        onNothingSelected: () => _goToLocations(context),
        onPermissionSelected: () => _checkPermission(context),
      ),
    );
  }
}
