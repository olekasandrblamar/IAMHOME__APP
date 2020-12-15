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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _buildDeviceCode(WatchModel watchModel) {
    var deviceMac = watchModel.deviceId;
    var deviceName = watchModel.deviceName;
    if (Platform.isAndroid && deviceMac != null && deviceMac.length > 5) {
      return deviceMac.substring(deviceMac.length - 5).replaceAll(":", "");
    }else if(Platform.isIOS && deviceName!=null){
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
                          _connectionStatus
                              ? 'Connected'
                              : 'Not Connected',
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
        onTap: ()  => {
          openDetailsScreen(context, index)
        },
      ),
    );
  }

  void openDetailsScreen(BuildContext context,int index) async{
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
