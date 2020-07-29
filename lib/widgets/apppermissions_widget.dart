import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:ceras/theme.dart';

class AppPermissions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Permissions',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              var hasOpened = openAppSettings();
              debugPrint('App Settings opened: ' + hasOpened.toString());
            },
            color: Colors.black,
          )
        ],
      ),
      backgroundColor: AppTheme.background,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Center(
          child: ListView(
              children: Permission.values
                  .where((Permission permission) {
                    return permission == Permission.camera ||
                        permission == Permission.location ||
                        permission == Permission.notification;
                  })
                  .map((Permission permission) => PermissionWidget(permission))
                  .toList()),
        ),
      ),
    );
  }
}

class PermissionWidget extends StatefulWidget {
  const PermissionWidget(this._permission);

  final Permission _permission;

  @override
  _PermissionState createState() => _PermissionState(_permission);
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState(this._permission);

  final Permission _permission;
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get getPermissionName {
    if (_permission == Permission.camera) {
      return 'Camera';
    }

    if (_permission == Permission.location) {
      return 'Location';
    }

    if (_permission == Permission.notification) {
      return 'Notifications';
    }

    return '';
  }

  String get getPermissionStatus {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return 'Access Denied';
      case PermissionStatus.granted:
        return 'Access Granted';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _permissionStatus != Permission.unknown
        ? Container(
            margin: EdgeInsets.only(
              bottom: 10,
            ),
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
                            color: Colors.green,
                          )
                        : Icon(
                            Icons.remove_circle,
                            color: Colors.red,
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
          )
        : Container();
  }
}
