import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/models/trackers/tracker_data_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import 'dart:io';
import 'dart:convert';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();

  Temperature _lastTemperature;

  BloodPressure _bloodPressure;

  Calories _lastCalories;

  DailySteps _lastSteps;

  OxygenLevel _oxygenLevel;

  HeartRate _lastHr;

  bool _paused = false;

  final eventChannel = EventChannel("ceras.iamhome.mobile/device_events");

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('Got state ${state}');
    switch (state) {
      case AppLifecycleState.resumed:
        if (!Platform.isIOS) {
          _goToLogin();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    _initData();
    WidgetsBinding.instance.addObserver(this);

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> _initData() async {
    try {
      // bool didAuthenticate = await auth.authenticateWithBiometrics(
      //   localizedReason: 'Please authenticate to show your data',
      //   useErrorDialogs: true,
      //   stickyAuth: true,
      // );
      //
      // if (!didAuthenticate) {
      //   return _goToLogin();
      // }
      //
      // //This code is to refresh the acccess token
      // final accessToken =
      //     await Provider.of<AuthProvider>(context, listen: false).authToken;
      //
      // if (accessToken == null) {
      //   return _goToLogin();
      // }

      // await _loadTemperature();
      // await _loadBloodPressure();
      // await _loadHeartRate();
      // await _loadCalories();
      // await _loadSteps();
      // await _loadOxygenLevel();

      _loadTemperature();
      _loadBloodPressure();
      _loadHeartRate();
      _loadCalories();
      _loadSteps();
      _loadOxygenLevel();
    } on PlatformException catch (e) {
      print(e);
      _goToLogin();
    }
  }

  void _gotoListPage() async {
    await Navigator.of(context).pushReplacementNamed(
      routes.SetupHomeRoute,
    );
  }

  void _readDataFromDevice(String dataType) async {
    print('Loading data type $dataType');
    var deviceList = await Provider.of<DevicesProvider>(context, listen: false)
        .getDevicesData();
    var device = deviceList[0];
    final requestData = {'deviceType':device.watchInfo.deviceType,'readingType':dataType};
    var request = json.encode(requestData);
    //var currentTemp = _lastTemperature;
    print('Sending request $request');
    switch(dataType){
      case 'TEMPERATURE' :{
        setState(() {
          _lastTemperature = null;
        });
      }break;
      case 'HR' :{
        setState(() {
          _lastHr = null;
        });
      }break;
      case 'O2' :{
        setState(() {
          _oxygenLevel = null;
        });
      }break;
      case 'BP' :{
        setState(() {
          _bloodPressure = null;
        });
      }break;
      default :{}
      break;
    }

    var subscription = eventChannel.receiveBroadcastStream(requestData).listen((event) {
      final returnData = json.decode(event);
      switch(dataType){
        case 'TEMPERATURE' :{
          if(returnData['countDown'] == 0) {
            var updatedTemp = Temperature();
            updatedTemp.celsius = returnData['celsius'];
            updatedTemp.fahrenheit = returnData['fahrenheit'];
            updatedTemp.measureTime = DateTime.now();
            setState(() {
              _lastTemperature = updatedTemp;
            });
          }
        }
        break;
        case 'HR' :{
          if(returnData['rate'] != 0) {
            var updatedHr = HeartRate();
            updatedHr.heartRate = returnData['heartRate'];
            updatedHr.measureTime = DateTime.now();
            setState(() {
              _lastHr = updatedHr;
            });
          }
        }
        break;
        case 'BP' :{
          if(returnData['systolic'] != 0) {
            var updatedBp = BloodPressure();
            updatedBp.systolic = returnData['systolic'];
            updatedBp.distolic = returnData['diastolic'];
            updatedBp.measureTime = DateTime.now();
            setState(() {
              _bloodPressure = updatedBp;
            });
          }
        }
        break;
        case 'O2' :{
          if(returnData['oxygenLevel'] != 0) {
            var updateo2 = OxygenLevel();
            updateo2.oxygenLevel = returnData['oxygenLevel'];
            updateo2.measureTime = DateTime.now();
            setState(() {
              _oxygenLevel = updateo2;
            });
          }
        }
        break;
        default :{

        }
        break;
      }
    },onError: (dynamic error){
      print('Got error $error for data type $dataType');
    },onDone: (){
      print('completed for $dataType');
    },cancelOnError: true);
  }

  void _goToLogin() async {
    await Navigator.of(context).pushReplacementNamed(
      routes.LoginRoute,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMMd().format(date.toLocal());
  }

  String _formatTime(DateTime date) {
    return DateFormat.jm().format(date.toLocal());
  }

  Future<void> _loadTemperature() async {
    var temperature = await Provider.of<DevicesProvider>(context, listen: false)
        .getLatestTemperature();

    setState(() {
      _lastTemperature = temperature;
    });
  }

  Future<void> _loadBloodPressure() async {
    var bloodPressure =
        await Provider.of<DevicesProvider>(context, listen: false)
            .getLatestBloodPressure();

    setState(() {
      _bloodPressure = bloodPressure;
    });
  }

  Future<void> _loadHeartRate() async {
    var heartRate = await Provider.of<DevicesProvider>(context, listen: false)
        .getLatestHeartRate();

    setState(() {
      _lastHr = heartRate;
    });
  }

  Future<void> _loadCalories() async {
    var calories = await Provider.of<DevicesProvider>(context, listen: false)
        .getLatestCalories();

    setState(() {
      _lastCalories = calories;
    });
  }

  Future<void> _loadSteps() async {
    var steps = await Provider.of<DevicesProvider>(context, listen: false)
        .getLatestSteps();

    setState(() {
      _lastSteps = steps;
    });
  }

  Future<void> _loadOxygenLevel() async {
    var oxygenLevel = await Provider.of<DevicesProvider>(context, listen: false)
        .getLatestOxygenLevel();

    setState(() {
      _oxygenLevel = oxygenLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _appLocalization = AppLocalizations.of(context);

    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   title: Text(
      //     'My Data',
      //   ),
      //   // actions: <Widget>[
      //   //   SwitchStoreIcon(),
      //   // ],
      // ),
      // backgroundColor: AppTheme.white,
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xffecf3fb),
        ),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              // backgroundColor: Colors.transparent,
              // elevation: 0.0,
              pinned: true,
              expandedHeight: 150.0,
              stretch: true,
              stretchTriggerOffset: 75,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'My Data',
                  style: TextStyle(
                    fontSize: 25,
                    // fontWeight: FontWeight.bold,
                    // color: Colors.black,
                  ),
                ),
                stretchModes: [
                  StretchMode.zoomBackground,
                  // StretchMode.blurBackground,
                  // StretchMode.fadeTitle,
                ],
                background: Image.asset(
                  'assets/images/clouds.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                 Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/icons/icons_themometer.png',
                                          height: 25,
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Temperature',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  IconButton(
                                        icon :Icon(Icons.refresh),
                                        onPressed: () {
                                          _readDataFromDevice('TEMPERATURE');
                                        },
                                      )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: (_lastTemperature != null
                                              ? _lastTemperature.fahrenheit
                                                  .toStringAsFixed(1)
                                              : '0'),
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(10, 0),
                                            child: Text(
                                              '°',
                                              //superscript is usually smaller in size
                                              textScaleFactor: 3,
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' F',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: FittedBox(
                              child: Text(
                                _lastTemperature != null
                                    ? 'Last Updated: ' +
                                        _formatDate(
                                            _lastTemperature.measureTime) +
                                        ' ' +
                                        _formatTime(
                                            _lastTemperature.measureTime)
                                    : '--',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/icons/icons_heartbeat.png',
                                        height: 25,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Heart Rate',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon :Icon(Icons.refresh),
                                    onPressed: () {
                                      _readDataFromDevice('HR');
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: _lastHr != null
                                              ? _lastHr.heartRate.toString()
                                              : '0',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 2),
                                            child: Text(
                                              ' bpm',
                                              //superscript is usually smaller in size
                                              textScaleFactor: 2,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: FittedBox(
                              child: Text(
                                _lastHr != null
                                    ? 'Last Updated: ' +
                                        _formatDate(_lastHr.measureTime) +
                                        ' ' +
                                        _formatTime(_lastHr.measureTime)
                                    : '--',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/icons/icons_bloodpressure.png',
                                        height: 25,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Blood Pressure',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon :Icon(Icons.refresh),
                                    onPressed: () {
                                      _readDataFromDevice('BP');
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: _bloodPressure != null
                                              ? _bloodPressure.systolic
                                                      .toString() +
                                                  '/' +
                                                  _bloodPressure.distolic
                                                      .toString()
                                              : '0/0',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 2),
                                            child: Text(
                                              ' mmHg',
                                              //superscript is usually smaller in size
                                              textScaleFactor: 2,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: FittedBox(
                              child: Text(
                                _bloodPressure != null
                                    ? 'Last Updated: ' +
                                        _formatDate(
                                            _bloodPressure.measureTime) +
                                        ' ' +
                                        _formatTime(_bloodPressure.measureTime)
                                    : '--',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.asset(
                                        'assets/icons/icons_bloodpressure.png',
                                        height: 25,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        'Oxygen Level',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon :Icon(Icons.refresh),
                                    onPressed: () {
                                      _readDataFromDevice('O2');
                                    },
                                  )
                                ],
                              ),

                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: _oxygenLevel != null
                                              ? _oxygenLevel.oxygenLevel
                                                  .toString()
                                              : '0',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 2),
                                            child: Text(
                                              ' %',
                                              //superscript is usually smaller in size
                                              textScaleFactor: 2,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: FittedBox(
                              child: Text(
                                _oxygenLevel != null
                                    ? 'Last Updated: ' +
                                        _formatDate(_oxygenLevel.measureTime) +
                                        ' ' +
                                        _formatTime(_oxygenLevel.measureTime)
                                    : '--',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/icons_calories.png',
                                    height: 25,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Calories',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: _lastCalories != null
                                                ? _lastCalories.calories
                                                    .toString()
                                                : '0',
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          WidgetSpan(
                                            child: Transform.translate(
                                              offset: const Offset(2, 2),
                                              child: Text(
                                                ' Cals',
                                                //superscript is usually smaller in size
                                                textScaleFactor: 2,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: FittedBox(
                              child: Text(
                                _lastCalories != null
                                    ? 'Last Updated: ' +
                                        _formatDate(_lastCalories.measureTime) +
                                        ' ' +
                                        _formatTime(_lastCalories.measureTime)
                                    : '--',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/icons_dailysteps.png',
                                    height: 25,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Steps',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: (_lastSteps != null
                                              ? _lastSteps.steps.toString()
                                              : '0'),
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 2),
                                            child: Text(
                                              ' Steps',
                                              //superscript is usually smaller in size
                                              textScaleFactor: 2,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: FittedBox(
                              child: Text(
                                _lastSteps != null
                                    ? 'Last Updated: ' +
                                        _formatDate(_lastSteps.measureTime) +
                                        ' ' +
                                        _formatTime(_lastSteps.measureTime)
                                    : '--',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
