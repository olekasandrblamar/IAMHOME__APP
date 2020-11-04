import 'dart:convert';

import 'package:ceras/config/background_fetch.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupHomeScreen extends StatefulWidget {
  @override
  _SetupHomeScreenState createState() => _SetupHomeScreenState();
}

class _SetupHomeScreenState extends State<SetupHomeScreen> {
  List<DevicesModel> _deviceData = [];
  List<WatchModel> _deviceStatus = [];
  var _lastUpdated = '---';

  @override
  void initState() {
    // TODO: implement initState
    loadData();
    super.initState();
  }

  void loadData() async {
    var deviceData = await Provider.of<DevicesProvider>(context, listen: false)
        .getDevicesData();

    if (deviceData.isNotEmpty) {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final lastUpdate = prefs.getString('last_sync');

      print("Last updated at ${lastUpdate}");

      setState(() {
        _deviceData = deviceData;
        _deviceStatus = deviceData.map((e) => e.watchInfo).toList();
        _lastUpdated = lastUpdate;
      });
      var index=0;
      deviceData.forEach((device) {
        _getDeviceStatus(index++);
      });
    }
  }

  Future<void> _authenticate() async {
    var token =
        await Provider.of<AuthProvider>(context, listen: false).tryAuthLogin();

    if (!token) {
      return _goToLogin();
    }

    await Navigator.of(context).pushNamed(
      routes.DataRoute,
    );
  }

  void _goToLogin() async {
    await Navigator.of(context).pushNamed(
      routes.LoginRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SetupAppBar(name: 'My Devices'),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: _deviceData.isNotEmpty
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (int index = 0; index < _deviceData.length; index++)
                        _buildDevicesList(index),
                      // _buildNewDevice()
                    ],
                  ),
                )
              : _buildNewDevice(),
        ),
      ),
      bottomNavigationBar: _deviceData.isNotEmpty
          ? SafeArea(
              bottom: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 90,
                    padding: EdgeInsets.all(20),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.5),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text('Access Health Data'),
                      onPressed: () => _authenticate(),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: 0,
            ),
    );
  }

  void _getDeviceStatus(int index) async {
    String connectionInfo = json.encode(_deviceData[index].watchInfo);
    final connectionStatus = await BackgroundFetchData.platform.invokeMethod(
      'deviceStatus',
      <String, dynamic>{'connectionInfo': connectionInfo},
    ) as String;

    if (connectionStatus != "Error") {
      final WatchModel connectionStatusData = WatchModel.fromJson(
          json.decode(connectionStatus) as Map<String, dynamic>);

      if (!mounted) return;
      _deviceStatus[index] = connectionStatusData;
      setState(() {
        _deviceStatus = _deviceStatus;
      });
    }
  }

  Widget _buildDevicesList(int index) {
    var deviceData = _deviceData[index];
    var imageData = (deviceData?.deviceMaster != null &&
            deviceData?.deviceMaster['displayImage'] != null)
        ? deviceData?.deviceMaster['displayImage']
        : null;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 150,
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: Container(
                  height: 100.0,
                  width: 100.0,
                  child: FadeInImage(
                    placeholder: AssetImage(
                      'assets/images/placeholder.jpg',
                    ),
                    image: imageData != null
                        ? NetworkImage(
                            imageData,
                          )
                        : AssetImage(
                            'assets/images/placeholder.jpg',
                          ),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeInCurve: Curves.easeIn,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      (deviceData?.deviceMaster != null &&
                              deviceData?.deviceMaster['displayName'] != null)
                          ? deviceData?.deviceMaster['displayName']
                          : '',
                      style: AppTheme.title,
                    ),
                  ),
                  FittedBox(
                    child: Text(_deviceStatus[index].connected?'Connected':'--'),
                  ),
                  FittedBox(
                    child: Text('ID# ${_deviceStatus[index].deviceId ?? '--'}'),
                  ),
                  FittedBox(
                    child: Text('Last Synced - ${_lastUpdated}'),
                  ),
                ],
              )
            ],
          ),
        ),
        onTap: () => {
          Navigator.of(context).pushNamed(
            routes.SetupActiveRoute,
            arguments: {'deviceIndex': index},
          ),
        },
      ),
    );
  }

  Widget _buildNewDevice() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            margin: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                height: 150,
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Image.asset(
                        'assets/images/AddNewDeviceDefault.png',
                        height: 75,
                        width: 75,
                      ),
                    ),
                    FittedBox(
                      child: Text(
                        'Add New Device',
                        style: AppTheme.title,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () => {
                Navigator.of(context).pushNamed(
                  routes.SetupDevicesRoute,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
