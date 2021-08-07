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

class StorageScreen extends StatelessWidget {
  void _checkPermission(context) async {
    final status = await Permission.storage.request();

    if (PermissionStatus.granted == status) {
      _goToHome(context);
    } else {
      showAccessAlertDialog(context);
    }
  }

  dynamic _goToHome(context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('walthrough', false);

    return Navigator.of(context).pushReplacementNamed(
      routes.SetupHomeRoute,
    );
  }

  final AccessModel storageData = ACCESS_DATA[3];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: translateHeader(context),
      backgroundColor: AppTheme.white,
      body: AccessWidget(
        type: 'storage',
        accessData: storageData,
        onNothingSelected: () => _goToHome(context),
        onPermissionSelected: () => _checkPermission(context),
      ),
    );
  }
}
