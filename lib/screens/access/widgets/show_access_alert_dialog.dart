import 'package:ceras/config/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void showAccessAlertDialog(context) {
  final _appLocalization = AppLocalizations.of(context);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          _appLocalization.translate('access.alert.title'),
        ),
        content: Text(
          _appLocalization.translate('access.alert.description'),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              _appLocalization.translate('access.alert.buttons.close'),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(
              _appLocalization.translate('access.alert.buttons.open'),
            ),
          ),
        ],
      );
    },
  );
}
