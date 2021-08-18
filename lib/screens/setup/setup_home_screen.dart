import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ceras/config/background_fetch.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/screens/setup/setup_upgrade_screen.dart';
import 'package:ceras/screens/setup/widgets/bluetooth_notfound_widget.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
  var _blueToothEnabled = true;

  @override
  void initState() {
    checkInternetConnection();
    checkBlue();
    if (Platform.isAndroid) {
      checkPermissionStatus();
    }
    loadData();
    updateVersionCheck();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
        onPaused();
        break;
      case AppLifecycleState.paused:
        onInactive();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
    }
  }

  void onResumed() {
    print('resumed');
    var index = 0;
    if (!mounted) return;
    _deviceData.forEach((device) {
      _processSyncData(index);
    });
  }

  void onPaused() {
    print('paused');
  }

  void onInactive() {
    print('inactive');
  }

  void onDetached() {
    print('detach');
  }

  void checkPermissionStatus() async {
    if (await Permission.location.status == PermissionStatus.denied) {
      return _goToPermissions(context);
    }

    if (Platform.isAndroid) {
      if (await Permission.storage.status == PermissionStatus.denied) {
        return _goToPermissions(context);
      }
    }

    // if (await Permission.bluetooth.status == PermissionStatus.denied) {
    //   return _goToPermissions(context);
    // }

    if (await Permission.notification.status == PermissionStatus.denied) {
      return _goToPermissions(context);
    }

    // if (!await FlutterBlue.instance.isOn) {
    //   await Navigator.of(context).pushNamed(
    //     routes.BluetoothNotfoundRoute,
    //   );
    // }
  }

  void checkBlue() {
    FlutterBlue.instance.state.listen((BluetoothState event) async {
      if (event == BluetoothState.unauthorized || event == BluetoothState.off) {
        _blueToothEnabled = false;
        await Navigator.of(context).pushNamed(
          routes.BluetoothNotfoundRoute,
        );
      } else if (event == BluetoothState.on && !_blueToothEnabled) {
        _blueToothEnabled = true;
        await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) => SetupHomeScreen(),
              settings: const RouteSettings(name: routes.SetupHomeRoute),
            ),
            (Route<dynamic> route) => false);
      }
    });
  }

  dynamic _goToPermissions(context) async {
    return Navigator.of(context).pushNamed(
      routes.AppPermissionsRoute,
    );
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
      _getConnectionStatus(index++);
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
    var versionCheckDateInMillis = await prefs.getString('versionCheckDate');

    var currentTimeInMillis = DateTime.now().millisecondsSinceEpoch;
    var checkAndValidate = true;
    //if the prev version date doesn't exist set that value
    if (versionCheckDateInMillis == null) {
      await prefs.setString('versionCheckDate', currentTimeInMillis.toString());
      checkAndValidate = true;
    } else {
      var milliSecondsSinceLastCheck = DateTime.now().millisecondsSinceEpoch -
          int.parse(versionCheckDateInMillis);
      var dayInMillis = 1000 * 60 * 60 * 24;
      var daysSinceLastUpdate = milliSecondsSinceLastCheck / dayInMillis;

      //if the last validation is more than 3 days ago
      if (daysSinceLastUpdate > 3.0) {
        checkAndValidate = true;
        await prefs.setString(
            'versionCheckDate', currentTimeInMillis.toString());
      }
    }

    if (checkAndValidate) {
      appVersionCheck();
    }
  }

  void appVersionCheck() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    //Get the current version from the API
    var versionData = await Provider.of<DevicesProvider>(context, listen: false)
        .currentVersion();

    //if the version data exists
    if (versionData != null) {
      var _currentVersion = currentVersion
          .toString()
          .split('.')
          .map((e) => int.parse(e))
          .toList();

      //default the version to android
      var curStoreVersion = versionData.androidVersion.toString();

      //If the current platform is IOS get the is version
      if (Platform.isIOS) {
        curStoreVersion = versionData.iosVersion.toString();
      }

      //Split the version into major.minor.build
      var _latestStoreVersion =
          curStoreVersion.split('.').map((e) => int.parse(e)).toList();

      //Compare the versions and if the new version os greater than the current version update the app
      if (_latestStoreVersion[0] > _currentVersion[0] ||
          _latestStoreVersion[1] > _currentVersion[1] ||
          _latestStoreVersion[2] > _currentVersion[2]) {
        updateApp();
      }
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
                        onPressed: () {
                          _authenticate();
                          for (var i = 0; i < _deviceData.length; i++) {
                            _processSyncData(i);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 25,
              ));
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

  void _processSyncData(index) async {
    final connectionInfo = json.encode(_deviceData[index].watchInfo);

    final syncResponse = BackgroundFetchData.platform.invokeMethod(
      'syncData',
      //'connectDevice',
      <String, dynamic>{'connectionInfo': connectionInfo},
    );

    //Don't wait for the response
    syncResponse.then((value) {
      print('Syncing value $value');
    });
  }

  void _getConnectionStatus(int index) async {
    final connectionInfo = json.encode(_deviceData[index].watchInfo);
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

  void _getDeviceStatus(int index) async {
    final connectionInfo = json.encode(_deviceData[index].watchInfo);
    final deviceStatus = await BackgroundFetchData.platform.invokeMethod(
      'deviceStatus',
      <String, dynamic>{'connectionInfo': connectionInfo},
    ) as String;

    if (deviceStatus != 'Error') {
      print('Got connection info response $deviceStatus');
      final connectionStatusData = WatchModel.fromJson(
          json.decode(deviceStatus) as Map<String, dynamic>);

      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('connected', 'true');

      // setState(() {
      //   _connected = connectionStatusData.connected;
      //   _deviceId = connectionStatusData.deviceId;
      //   _batteryLevel = connectionStatusData.batteryStatus;
      // });
      if (connectionStatusData.upgradeAvailable) {
        _showUpgrade();
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('connected', 'false');
    }
  }

  void _showUpgrade() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Upgrade available',
          ),
          content: Text(
            'An upgrade to the device is aviailable. Do you want to Upgrade',
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                // _upgradeDevice();

                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (BuildContext context) => SetupUpgradeScreen(),
                      settings:
                          const RouteSettings(name: routes.SetupUpgradeRoute),
                    ),
                    (Route<dynamic> route) => false);
              },
              child: Text(
                'Ok',
              ),
            ),
          ],
        );
      },
    );
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
        onTap: () => openDetailsScreen(context, index),
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
                    child: CachedNetworkImage(
                      imageUrl: imageData,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      fadeInDuration: Duration(milliseconds: 200),
                      fadeInCurve: Curves.easeIn,
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/placeholder.jpg'),
                    )),
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
                        child: Text('Last Updated - $_lastUpdated'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
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
              onTap: () => {
                Navigator.of(context).pushNamed(
                  routes.SetupDevicesRoute,
                ),
              },
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
            ),
          ),
        ],
      ),
    );
  }
}
