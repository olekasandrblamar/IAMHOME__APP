import 'dart:convert';

import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:ceras/config/background_fetch.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

import '../data_screen.dart';
import 'widgets/bluetooth_notfound_widget.dart';

class SetupActiveScreen extends StatefulWidget {
  @override
  _SetupActiveScreenState createState() => _SetupActiveScreenState();
}

class _SetupActiveScreenState extends State<SetupActiveScreen>
    with WidgetsBindingObserver {
  static const platform = MethodChannel('ceras.iamhome.mobile/device');
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

  void _getDeviceStatus(String connectionInfo) async {
    final connectionStatus = await BackgroundFetchData.platform.invokeMethod(
      'deviceStatus',
      <String, dynamic>{'connectionInfo': connectionInfo},
    ) as String;

    if (connectionStatus != "Error") {
      print("Got connection info response ${connectionStatus}");
      final WatchModel connectionStatusData = WatchModel.fromJson(
          json.decode(connectionStatus) as Map<String, dynamic>);

      if (!mounted) return;

      setState(() {
        _connected = connectionStatusData.connected;
        _deviceId = connectionStatusData.deviceId;
      });
    }
  }

  void _changeLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final lastUpdate = prefs.getString('last_sync');
    final deviceType = prefs.getString('deviceType');

    final deviceData = DevicesModel.fromJson(
        json.decode(prefs.getString('deviceData')) as Map<String, dynamic>);

    print("Last updated at ${lastUpdate}");
    if (mounted) {
      setState(() {
        _lastUpdated = lastUpdate;
        _deviceType = deviceType;
        _deviceData = deviceData;
      });
    }
    final connectionInfo = prefs.getString('watchInfo');
    _setIsLoading(true);

    Future.delayed(Duration(seconds: 3), () {
      _getDeviceStatus(connectionInfo);
      _setIsLoading(false);
    });

    _showSuccessMessage();
  }

  void _syncDataFromDevice() async {
    _setIsLoading(true);

    await syncDataFromDevice();
    await _changeLastUpdated();
  }

  void _showSuccessMessage() {
    final snackBar = SnackBar(
      content: Text(
        'Sending Data To Your Doctor',
      ),
      duration: Duration(seconds: 1),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);

    _setIsLoading(false);
  }

  void _setIsLoading(bool loading) {
    if (mounted) {
      setState(() {
        isLoading = loading;
      });
    }
  }

  void _logout() async {
    var deviceType =
        await Provider.of<AuthProvider>(context, listen: false).deviceType;

    if (deviceType != null) {
      var disconnect = await platform.invokeMethod(
        'disconnect',
        <String, dynamic>{'deviceType': deviceType},
      ) as String;

      if (disconnect != null) {
        await Provider.of<AuthProvider>(context, listen: false).logout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Selected Device'),
      ),
      backgroundColor: AppTheme.white,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
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
                child: Text(
                  'Remove Device',
                ),
                onPressed: () => _logout(),
              ),
            ),
          ],
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
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              bottom: 5.0,
            ),
            child: Text(
              // _appLocalization.translate('setup.active.devicefound'),
              (_deviceData?.deviceMaster != null &&
                      _deviceData?.deviceMaster['displayName'] != null)
                  ? _deviceData?.deviceMaster['displayName'] + ' Tracker Device'
                  : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.18,
                color: Colors.red,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              bottom: 5.0,
            ),
            child: Text(
              'Device Details',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppTheme.title,
            ),
          ),
          SizedBox(
            height: 35,
          ),
          Container(
            height: 250.0,
            width: 250.0,
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
        ],
      ),
    );
  }

  List<Widget> _buildInfo(_appLocalization) {
    return [
      Container(
        child: Row(
          children: [
            Text(
              'Device',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.18,
              ),
            ),
            Text(
              ' | ',
            ),
            Text(
              // _appLocalization.translate('setup.active.devicefound'),
              _connected ? 'Connected' : '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.18,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 15,
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Last Synced',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 0.18,
                color: Color(0xFF797979),
              ),
            ),
            Text(
              '${_lastUpdated}',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                letterSpacing: 0.18,
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 10,
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Battery Level',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 0.18,
                color: Color(0xFF797979),
              ),
            ),
            Text(
              '--',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                letterSpacing: 0.18,
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 10,
      ),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ID Number',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 0.18,
                color: Color(0xFF797979),
              ),
            ),
            Text(
              '${_deviceId}',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                letterSpacing: 0.18,
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
