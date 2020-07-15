import 'package:flutter/material.dart';
import 'package:lifeplus/data/access_data.dart';
import 'package:lifeplus/models/access_model.dart';
import 'package:lifeplus/screens/access/widgets/access_widget.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';

import 'widgets/show_access_alert_dialog.dart';

class CameraScreen extends StatelessWidget {
  void _checkPermission(context) async {
    final status = await Permission.camera.request();

    if (PermissionStatus.granted == status) {
      _goToHome(context);
    } else {
      showAccessAlertDialog(context);
    }
  }

  dynamic _goToHome(context) {
    return Navigator.of(context).pushReplacementNamed(
      routes.SetupHomeRoute,
    );
  }

  final AccessModel cameraData = ACCESS_DATA[2];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: AccessWidget(
        accessData: cameraData,
        onNothingSelected: () => _goToHome(context),
        onPermissionSelected: () => _checkPermission(context),
      ),
    );
  }
}
