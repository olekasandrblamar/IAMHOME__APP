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

class BluetoothScreen extends StatelessWidget {
  void _checkPermission(context) async {
    final status = await Permission.bluetooth.request();

    // if (PermissionStatus.granted == status) {
    //   _goToHome(context);
    // } else {
    //   showAccessAlertDialog(context);
    // }

    _goToHome(context);
  }

  dynamic _goToHome(context) async {
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

  final AccessModel storageData = ACCESS_DATA[4];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: translateHeader(context),
      backgroundColor: AppTheme.white,
      body: AccessWidget(
        type: 'camera',
        accessData: storageData,
        onNothingSelected: () => _goToHome(context),
        onPermissionSelected: () => _checkPermission(context),
      ),
    );
  }
}
