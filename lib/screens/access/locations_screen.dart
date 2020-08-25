import 'package:ceras/widgets/translateheader_widget.dart';
import 'package:flutter/material.dart';
import 'package:ceras/data/access_data.dart';
import 'package:ceras/models/access_model.dart';
import 'package:ceras/screens/access/widgets/access_widget.dart';
import 'package:ceras/theme.dart';

import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';

import 'widgets/show_access_alert_dialog.dart';

class LocationsScreen extends StatelessWidget {
  void _checkPermission(context) async {
    var status = await Permission.location.request();
    status = await Permission.locationAlways.request();

    if (PermissionStatus.granted == status) {
      _goToCamera(context);
    } else {
      showAccessAlertDialog(context);
    }
  }

  dynamic _goToCamera(context) {
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
        onPermissionSelected: () => _checkPermission(context),
      ),
    );
  }
}
