import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/screens/setup/setup_upgrade_screen.dart';
import 'package:circular_countdown/circular_countdown.dart';
import 'package:flutter/material.dart';
import 'package:ceras/config/background_fetch.dart';
import 'package:ceras/theme.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ceras/config/navigation_service.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

import 'widgets/bluetooth_notfound_widget.dart';

class SetupActiveScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  SetupActiveScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _SetupActiveScreenState createState() => _SetupActiveScreenState();
}

class _SetupActiveScreenState extends State<SetupActiveScreen>
    with WidgetsBindingObserver {
  static const platform = MethodChannel('ceras.iamhome.mobile/device');
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _deviceIndex;
  String _lastUpdated;
  DevicesModel _deviceData;
  String _deviceId = '---';
  String _batteryLevel = '---';
  bool _connected = true;
  bool isLoading = true;
  TimeCircularCountdown _currentCountDown;

  @override
  void initState() {
    if (widget.routeArgs != null) {
      _deviceIndex = widget.routeArgs['deviceIndex'];
    }
    print('Got index $_deviceIndex');

    // _changeLastUpdated();
    _loadDeviceData().then((value) => _syncDataFromDevice());

    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

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

  Future<void> _getDeviceStatus(String connectionInfo) async {
    final connectionStatus = await BackgroundFetchData.platform.invokeMethod(
      'deviceStatus',
      <String, dynamic>{'connectionInfo': connectionInfo},
    ) as String;

    if (connectionStatus != 'Error') {
      print('Got connection info response $connectionStatus');
      final connectionStatusData = WatchModel.fromJson(
          json.decode(connectionStatus) as Map<String, dynamic>);

      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('connected', 'true');

      setState(() {
        _connected = connectionStatusData.connected;
        _deviceId = connectionStatusData.deviceId;
        _batteryLevel = connectionStatusData.batteryStatus;
      });
      if (connectionStatusData.upgradeAvailable) {
        _showUpgrade();
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('connected', 'false');
    }
  }

  void _changeLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final lastUpdate = prefs.getString('last_sync');

    print('Last updated at $lastUpdate');

    if (mounted) {
      setState(() {
        _lastUpdated = lastUpdate;
      });
    }

    await _loadDeviceData();

    final connectionInfo = await getDeviceInfoString();
    if (connectionInfo != null) {
      _setIsLoading(true);

      Future.delayed(Duration(seconds: 3), () {
        _getDeviceStatus(connectionInfo).then((value){
          _setIsLoading(false);
        });
        _setIsLoading(false);
      });
    }

    // _showSuccessMessage();
  }

  Future<void> _loadDeviceData() async {
    var deviceData = await Provider.of<DevicesProvider>(context, listen: false)
        .getDeviceData(_deviceIndex);

    if (mounted) {
      setState(() {
        _deviceData = deviceData;
      });
    }
  }

  void _syncDataFromDevice() async {
    //_setIsLoading(true);
    var deviceInfoString = await getDeviceInfoString();
    print('Got device info string $deviceInfoString');
    _changeLastUpdated();
    await readDataFromDevice(deviceInfoString);
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

  void _removeDevice() async {
    var connectionInfo = await getDeviceInfoString();

    var disconnect = await platform.invokeMethod(
      'disconnect',
      <String, dynamic>{'connectionInfo': connectionInfo},
    ) as String;

    if (disconnect != null) {
      var removeDeviceData =
          await Provider.of<DevicesProvider>(context, listen: false)
              .removeDevice(_deviceIndex);

      if (removeDeviceData) {
        _loadCountDownTimer(20, 'Resetting Device');
      }
    }

  }

  Future<String> getDeviceInfoString() async{
    var deviceData = await Provider.of<DevicesProvider>(context, listen: false)
        .getDeviceData(_deviceIndex);
    return JsonEncoder().convert(deviceData.watchInfo);
  }

  void _loadCountDownTimer(int seconds, String type) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.6), // Background color
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: Duration(
        milliseconds: 400,
      ), // How long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 100),
              TimeCircularCountdown(
                unit: CountdownUnit.second,
                countdownTotal: seconds,
                onFinished: () {
                  NavigationService.goBackHome();
                },
                onCanceled: (CountdownUnit unit, int remaining) {},
                diameter: 200,
                countdownTotalColor: Colors.white,
                countdownCurrentColor: Colors.blue,
                countdownRemainingColor: Colors.blue,
                strokeWidth: 10,
                gapFactor: 2,
                textStyle: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm',
          ),
          content: Text(
            'Do you want to remove the device',
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
                _removeDevice();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Selected Device'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.highlight_off),
        //     onPressed: () => _showDialog(),
        //   )
        // ],
      ),
      backgroundColor: AppTheme.white,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            // child: StreamBuilder<BluetoothState>(
            //   stream: FlutterBlue.instance.state,
            //   initialData: BluetoothState.unknown,
            //   builder: (c, snapshot) {
            //     final state = snapshot.data;
            //     if (state == BluetoothState.on) {
            //       return ;
            //     }
            //     return buildBluetoothOff(context);
            //   },
            // ),
            child: buildDeviceConnect(context),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Container(
            //   // width: 200,
            //   // height: 90,
            //   padding: EdgeInsets.all(20),
            //   child: Ink(
            //     decoration: const ShapeDecoration(
            //       color: Colors.red,
            //       shape: CircleBorder(),
            //     ),
            //     child: IconButton(
            //       icon: Icon(Icons.delete),
            //       color: Colors.white,
            //       onPressed: () => _showDialog(),
            //     ),
            //   ),
            // ),

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
                  'Reset',
                ),
                onPressed: () => _showDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDeviceConnect(context) {
    final _appLocalization = AppLocalizations.of(context);
    print('device data ${json.encode(_deviceData?.deviceMaster)}');
    var imageData = (_deviceData!=null && _deviceData?.deviceMaster != null &&
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
                  ? _deviceData?.deviceMaster['displayName']
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
              child: CachedNetworkImage(
                imageUrl: imageData,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                fadeInDuration: Duration(milliseconds: 200),
                fadeInCurve: Curves.easeIn,
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/placeholder.jpg'),
              )),
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
              '${_batteryLevel}%',
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
              'MAC ID',
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
