import 'dart:io';

import 'package:ceras/config/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:ceras/theme.dart';

class AppPermissions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appLocalization.translate('settings.permissions.title'),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(Icons.settings),
        //     onPressed: () {
        //       var hasOpened = openAppSettings();
        //       debugPrint('App Settings opened: ' + hasOpened.toString());
        //     },
        //   )
        // ],
      ),
      backgroundColor: AppTheme.background,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Center(
          child: ListView(
              children: Permission.values
                  .where((Permission permission) {
                    return permission == Permission.location ||
                        permission == Permission.notification;
                  })
                  .map((Permission permission) =>
                      PermissionWidget(permission, _appLocalization))
                  .toList()),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200,
              height: 90,
              padding: EdgeInsets.all(20),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.5),
                ),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text('Open Settings'),
                onPressed: () {
                  var hasOpened = openAppSettings();
                  debugPrint('App Settings opened: ' + hasOpened.toString());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionWidget extends StatefulWidget {
  const PermissionWidget(this._permission, this._appLocalization);

  final Permission _permission;
  final _appLocalization;

  @override
  _PermissionState createState() =>
      _PermissionState(_permission, _appLocalization);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permission, this._appLocalization);

  final AppLocalizations _appLocalization;
  final Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  _requestPermisson() async {
    if (PermissionStatus.denied == _permissionStatus) {
      if (_permission == Permission.notification) {
        var status = await Permission.notification.request();

        if (PermissionStatus.granted == status) {
          setState(() {
            _permissionStatus = PermissionStatus.granted;
          });
        }
      }

      if (_permission == Permission.location) {
        var status = Platform.isIOS
            ? await Permission.location.request()
            : await Permission.locationAlways.request();

        if (PermissionStatus.granted == status) {
          setState(() {
            _permissionStatus = PermissionStatus.granted;
          });
        }
      }
    } else {
      await openAppSettings();
    }
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Color(0xffc10b03);
      case PermissionStatus.granted:
        return Color(0xff008bc6);
      default:
        return Colors.grey;
    }
  }

  String get getPermissionName {
    if (_permission == Permission.camera) {
      return _appLocalization
          .translate('settings.permissions.permissionname.camera');
    }

    if (_permission == Permission.location) {
      return _appLocalization
          .translate('settings.permissions.permissionname.location');
    }

    if (_permission == Permission.notification) {
      return _appLocalization
          .translate('settings.permissions.permissionname.notifications');
    }

    return '';
  }

  String get getPermissionStatus {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return _appLocalization
            .translate('settings.permissions.permissionstatus.denied');
      case PermissionStatus.granted:
        return _appLocalization
            .translate('settings.permissions.permissionstatus.granted');
      default:
        return _appLocalization
            .translate('settings.permissions.permissionstatus.unknown');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _permissionStatus != Permission.unknown
        ? Container(
            margin: EdgeInsets.only(
              bottom: 10,
            ),
            child: InkWell(
              onTap: () => _requestPermisson(),
              child: Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        getPermissionName,
                      ),
                      subtitle: Text(
                        getPermissionStatus,
                        style: TextStyle(color: getPermissionColor()),
                      ),
                      trailing: _permissionStatus == PermissionStatus.granted
                          ? Icon(
                              Icons.check_circle,
                              color: Color(0xff008bc6),
                            )
                          : Icon(
                              Icons.remove_circle,
                              color: Color(0xffc10b03),
                            ),
                    ),
                    // Divider(
                    //   height: 0,
                    // ),
                    // Container(
                    //   child: ListTile(
                    //     title: Text('Capture Images'),
                    //     subtitle: Text('Capture images for '),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          )
        : Container();
  }
}
