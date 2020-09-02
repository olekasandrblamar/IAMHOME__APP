import 'dart:convert';

import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:flutter/material.dart';
import 'package:ceras/config/background_fetch.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

import 'widgets/bluetooth_notfound_widget.dart';

class SetupActiveScreen extends StatefulWidget {
  @override
  _SetupActiveScreenState createState() => _SetupActiveScreenState();
}

class _SetupActiveScreenState extends State<SetupActiveScreen>
    with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _lastUpdated = null;
  String _deviceType = null;
  DevicesModel _deviceData = null;
  String _deviceId = null;
  bool _connected = true;
  bool isLoading = true;

  @override
  void initState() {
    // _changeLastUpdated();
    _syncDataFromDevice();
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
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
    _syncDataFromDevice();
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

  void _changeLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final lastUpdate = prefs.getString('last_sync');
    final deviceType = prefs.getString('deviceType');

    final deviceData = DevicesModel.fromJson(
        json.decode(prefs.getString('deviceData')) as Map<String, dynamic>);

    print("Last updated at ${lastUpdate}");
    setState(() {
      _lastUpdated = lastUpdate;
      _deviceType = deviceType;
      _deviceData = deviceData;
    });
    final connectionInfo = prefs.getString('watchInfo');
    final connectionStatus = await BackgroundFetchData.platform.invokeMethod(
      'deviceStatus',
      //'connectDevice',
      <String, dynamic>{'connectionInfo': connectionInfo},
    ) as String;
    if (connectionStatus != "Error") {
      print("Got connection info response ${connectionStatus}");
      final WatchModel connectionStatusData = WatchModel.fromJson(
          json.decode(connectionStatus) as Map<String, dynamic>);

      setState(() {
        _connected = connectionStatusData.connected;
        _deviceId = connectionStatusData.deviceId;
      });
    }
    setState(() {
      isLoading = false;
    });

    _showSuccessMessage();
  }

  void _syncDataFromDevice() async {
    setState(() {
      isLoading = true;
    });

    await syncDataFromDevice();
    await _changeLastUpdated();
  }

  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content: Text(
        'Data is transmitted',
      ),
      duration: Duration(seconds: 1),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: SetupAppBar(),
      backgroundColor: AppTheme.white,
      body: SafeArea(
        bottom: true,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.on) {
                return buildDeviceConnect(context);
              }
              return buildBluetoothOff(context);
            },
          ),
        ),
      ),
    );
  }

  Widget buildDeviceConnect(context) {
    final _appLocalization = AppLocalizations.of(context);

    var imageData = (_deviceData?.deviceMaster != null &&
            _deviceData?.deviceMaster['displayImage'] != null)
        ? _deviceData?.deviceMaster['displayImage']
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 200.0,
            width: 200.0,
            padding: const EdgeInsets.all(40.0),
            margin: const EdgeInsets.all(40.0),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: _connected ? Color(0xff008bc6) : Colors.red,
              ),
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: _connected ? Color(0xff008bc6) : Colors.red,
                  blurRadius: 60.0,
                  spreadRadius: 30.0,
                )
              ],
            ),
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
          SizedBox(
            height: 35,
          ),
          if (isLoading)
            CircularProgressIndicator()
          else
            ..._buildInfo(_appLocalization),
          SizedBox(
            height: 25,
          ),
          Container(
            width: 150,
            height: 75,
            padding: EdgeInsets.all(10),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.5),
              ),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text(
                _appLocalization.translate('setup.active.syncdata'),
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              onPressed: () async {
//                  return Navigator.of(context).pushReplacementNamed(
//                    routes.SetupHomeRoute,
//                  );
                await _syncDataFromDevice();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInfo(_appLocalization) {
    return [
      Container(
        padding: const EdgeInsets.only(
          bottom: 5.0,
        ),
        child: Text(
          // _appLocalization.translate('setup.active.devicefound'),
          (_deviceData?.deviceMaster != null &&
                  _deviceData?.deviceMaster['displayName'] != null)
              ? _deviceData?.deviceMaster['displayName']
              : '',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTheme.title,
        ),
      ),
      Container(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          // _appLocalization.translate('setup.active.devicefound'),
          // Device Id -
          '${_deviceId}',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18,
            letterSpacing: 0.18,
            color: Color(0xFF17262A),
          ),
        ),
      ),
      Container(
        child: Text(
          // _appLocalization.translate('setup.active.lastconnected') +
          '${_lastUpdated}.',
          textAlign: TextAlign.center,
          style: AppTheme.subtitle,
        ),
      ),
    ];
  }
}
