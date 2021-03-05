import 'dart:convert';
import 'dart:io';

import 'package:ceras/config/background_fetch.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SetupHomeScreen extends StatefulWidget {
  @override
  _SetupHomeScreenState createState() => _SetupHomeScreenState();
}

class _SetupHomeScreenState extends State<SetupHomeScreen>
    with WidgetsBindingObserver {
  var connectivitySubscription;

  List<DevicesModel> _deviceData = [];
  List<WatchModel> _deviceStatus = [];
  var _lastUpdated = '---';
  var _connectionStatus = false;

  @override
  void initState() {
    checkInternetConnection();
    loadData();
    updateVersionCheck();
    super.initState();
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();

    super.dispose();
  }

  void checkInternetConnection() {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        return Navigator.of(context).pushReplacementNamed(
          routes.ConnectionNotfoundRoute,
        );
      }
    });
  }

  void loadData() async {
    try {
      var deviceData =
          await Provider.of<DevicesProvider>(context, listen: false)
              .getDevicesData();

      if (deviceData.isNotEmpty) {
        if (!mounted) return;
        _changeLastUpdated();
        setState(() {
          _deviceData = deviceData;
          _deviceStatus = deviceData.map((e) => e.watchInfo).toList();
          _loadDeviceState(deviceData);
        });
      }
    } catch (error) {
      await Navigator.of(context).pushReplacementNamed(
        routes.UnabletoconnectRoute,
      );
    }
  }

  void _loadDeviceState(List<DevicesModel> deviceList) {
    var index = 0;
    deviceList.forEach((device) {
      _getDeviceStatus(index++);
    });
  }

  Future<void> _authenticate() async {
    //
    // if (!token) {
    //   return _goToLogin();
    // }
    //
    // await Navigator.of(context).pushNamed(
    //   routes.DataRoute,
    // );
    return _goToLogin();
  }

  void _goToLogin() async {
    await Navigator.of(context).pushNamed(
      routes.LoginRoute,
    );
  }

  void updateVersionCheck() async {
    final prefs = await SharedPreferences.getInstance();
    var versionCheckDate = await prefs.getString('versionCheckDate');

    // DateTime d = DateTime.now();

    // var currentDate = d.setDate(d.getDate());
    // if (versionCheckDate == null) {
    //   await prefs.setString('versionCheckDate', currentDate.toString());
    // }

    // // var daysFromNow: any = d.setDate(d.getDate() - 3); // three days fromNow
    // var millisec = currentDate - DateTime(int.parse(versionCheckDate));
    // var seconds = double.parse((millisec / 1000).toFixed(0));

    // /* Checking if current date is greater than 3 days
    //             and if it is greater than 3 days check fior update
    //     */
    // if (seconds > 259200) {
    //   await prefs.setString('versionCheckDate', currentDate.toString());
    //   await appVersionCheck();
    // }
  }

  Future<void> appVersionCheck() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    var versionData = await Provider.of<AuthProvider>(context, listen: false)
        .checkAppVersion();

    if (versionData.isNotEmpty) {
      // var _currentVersion =
      //     JSON.stringify(currentVersion.toString().split('.'));
      // var _latestVersioniOS =
      //     JSON.stringify(versionData.ios.toString().split('.'));
      // var _latestVersionAndroid =
      //     JSON.stringify(versionData.android.toString().split('.'));

      // if (Platform.isIOS) {
      //   if (_latestVersioniOS > _currentVersion) {
      //     updateApp();
      //   }
      // } else {
      //   if (_latestVersionAndroid > _currentVersion) {
      //     updateApp();
      //   }
      // }
    }
  }

  void updateApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Update Available',
          ),
          content: Text(
            'Do you want to update the app to enjoy latest features?',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Ok',
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                if (Platform.isIOS) {
                  await launch(
                    'https://apps.apple.com/us/app/ceras/id1525595039?mt=8',
                  );
                } else {
                  await launch(
                    'https://play.google.com/store/apps/details?id=com.cerashealth.ceras',
                  );
                }
              },
            ),
          ],
        );
      },
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
          // child: _deviceData.isNotEmpty ?
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int index = 0; index < _deviceData.length; index++)
                  _buildDevicesList(index),
                _buildNewDevice()
              ],
            ),
          ),
          // : _buildNewDevice(),
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
          : SafeArea(
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
            ),
    );
  }

  String _buildDeviceCode(WatchModel watchModel) {
    var deviceMac = watchModel.deviceId;
    var deviceName = watchModel.deviceName;
    if (Platform.isAndroid && deviceMac != null && deviceMac.length > 5) {
      return deviceMac.substring(deviceMac.length - 5).replaceAll(":", "");
    } else if (Platform.isIOS && deviceName != null) {
      return deviceName.substring(deviceName.length - 4);
    }
    return deviceMac;
  }

  void _changeLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final lastUpdate = prefs.getString('last_sync');

    // final connected = prefs.getString("connected");
    // _connectionStatus = _deviceStatus[0].connected || (connected!=null && connected == "true");
    // print("connection status ${_connectionStatus}");
    _lastUpdated =
        lastUpdate ?? DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now());
  }

  void _getDeviceStatus(int index) async {
    String connectionInfo = json.encode(_deviceData[index].watchInfo);
    final connectionStatus = await BackgroundFetchData.platform.invokeMethod(
      'connectionStatus',
      <String, dynamic>{'connectionInfo': connectionInfo},
    ) as bool;

    print('Connection Status $connectionStatus');
    setState(() {
      _connectionStatus = connectionStatus;
    });
    // if (connectionStatus != "Error") {
    //   final WatchModel connectionStatusData = WatchModel.fromJson(
    //       json.decode(connectionStatus) as Map<String, dynamic>);
    //
    //   if (!mounted) return;
    //   _deviceStatus[index] = connectionStatusData;
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.reload();
    //   final lastUpdate = prefs.getString('last_sync');
    //
    //   // setState(() {
    //   //   _deviceStatus = _deviceStatus;
    //   //   _lastUpdated = lastUpdate ??
    //   //       DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now());
    //   // });
    // }
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
                padding: EdgeInsets.all(10),
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
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        child: Text(
                          (deviceData?.deviceMaster != null &&
                                  deviceData?.deviceMaster['displayName'] !=
                                      null)
                              ? deviceData?.deviceMaster['displayName']
                              : '',
                          style: AppTheme.title,
                        ),
                      ),
                      SizedBox(height: 10),
                      FittedBox(
                        child: Text(
                          _connectionStatus ? 'Connected' : 'Not Connected',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      FittedBox(
                        child: Text(
                            'ID# ${_buildDeviceCode(_deviceStatus[index]) ?? '--'}'),
                      ),
                      SizedBox(height: 5),
                      FittedBox(
                        child: Text('Last Updated - ${_lastUpdated}'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () => {openDetailsScreen(context, index)},
      ),
    );
  }

  void openDetailsScreen(BuildContext context, int index) async {
    await Navigator.of(context).pushNamed(
      routes.SetupActiveRoute,
      arguments: {'deviceIndex': index},
    );
    print('Device back');
    loadData();

    // print('Got back from details');
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.reload();
    // final lastUpdate = prefs.getString('last_sync');
    // var connectionStatus = prefs.getString('connected');
    // print('Got connection status ${connectionStatus!=null && connectionStatus=='true'}');
    //
    // // final connected = prefs.getString("connected");
    // // _connectionStatus = _deviceStatus[0].connected || (connected!=null && connected == "true");
    // // print("connection status ${_connectionStatus}");
    // setState(() {
    //   _lastUpdated =
    //       lastUpdate ?? DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now());
    //   _connectionStatus = connectionStatus!=null && connectionStatus=='true';
    // });
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
