import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/models/trackers/tracker_data_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  var currentPageValue = 0.0;
  int _currentPage = 0;
  var trackers = [1, 2, 3, 4, 5, 6];

  bool canScroll;

  final PageController _pageController = PageController(
    initialPage: 0,
    // viewportFraction: 0.8,
  );

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

    _pageController.addListener(() {
      setState(() {
        currentPageValue = _pageController.page;
      });
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
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
    setState(() {
      canScroll = false;
    });
    print('Loading data type $dataType');
    var deviceList = await Provider.of<DevicesProvider>(context, listen: false)
        .getDevicesData();
    var device = deviceList[0];
    final requestData = {
      'deviceType': device.watchInfo.deviceType,
      'readingType': dataType
    };
    var request = json.encode(requestData);
    //var currentTemp = _lastTemperature;
    print('Sending request $request');
    switch (dataType) {
      case 'TEMPERATURE':
        {
          setState(() {
            _lastTemperature = null;
          });
        }
        break;
      case 'HR':
        {
          setState(() {
            _lastHr = null;
          });
        }
        break;
      case 'O2':
        {
          setState(() {
            _oxygenLevel = null;
          });
        }
        break;
      case 'BP':
        {
          setState(() {
            _bloodPressure = null;
          });
        }
        break;
      default:
        {}
        break;
    }

    var subscription =
        eventChannel.receiveBroadcastStream(requestData).listen((event) {
      final returnData = json.decode(event);
      switch (dataType) {
        case 'TEMPERATURE':
          {
            if (returnData['countDown'] == 0) {
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
        case 'HR':
          {
            if (returnData['rate'] != 0) {
              var updatedHr = HeartRate();
              updatedHr.heartRate = returnData['heartRate'];
              updatedHr.measureTime = DateTime.now();
              setState(() {
                _lastHr = updatedHr;
              });
            }
          }
          break;
        case 'BP':
          {
            if (returnData['systolic'] != 0) {
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
        case 'O2':
          {
            if (returnData['oxygenLevel'] != 0) {
              var updateo2 = OxygenLevel();
              updateo2.oxygenLevel = returnData['oxygenLevel'];
              updateo2.measureTime = DateTime.now();
              setState(() {
                _oxygenLevel = updateo2;
              });
            }
          }
          break;
        default:
          {}
          break;
      }
    }, onError: (dynamic error) {
      print('Got error $error for data type $dataType');
      setState(() {
        canScroll = true;
      });
    }, onDone: () {
      print('completed for $dataType');
      setState(() {
        canScroll = true;
      });
    }, cancelOnError: true);
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
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'My Health Data',
        ),
        // actions: <Widget>[
        //   SwitchStoreIcon(),
        // ],
      ),
      // backgroundColor: AppTheme.white,
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xffecf3fb),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: trackers.length,
                itemBuilder: (ctx, i) => Transform(
                  transform: Matrix4.identity()..rotateX(currentPageValue - i),
                  child: (i == 0)
                      ? _tracker1()
                      : (i == 1)
                          ? _tracker2()
                          : (i == 2)
                              ? _tracker3()
                              : (i == 3)
                                  ? _tracker4()
                                  : (i == 4)
                                      ? _tracker5()
                                      : (i == 5)
                                          ? _tracker6()
                                          : Container(),
                ),
                physics: canScroll
                    ? ScrollPhysics()
                    : NeverScrollableScrollPhysics(),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < trackers.length; i++)
                    if (i == _currentPage)
                      _buildSlideDots(context, true, i)
                    else
                      _buildSlideDots(context, false, i)
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tracker1() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            ..._buildTrackerHeader('Temperature', 'temperature'),
            if (_lastTemperature != null) ..._loadTemperatureData(),
            if (_lastTemperature == null) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  List<Widget> _loadTemperatureData() {
    return [
      Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Expanded(
            //   flex: 6,
            // child: FittedBox(
            // child:
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: (_lastTemperature != null
                      ? _lastTemperature.fahrenheit.toStringAsFixed(1)
                      : '0'),
                  style: TextStyle(
                    fontSize: 50,
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
                      style: TextStyle(color: Colors.black),
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
              // ),
              // ),
            ),
          ],
        ),
      ),
      _buildLastUpdatedTime(_lastTemperature.measureTime),
      const SizedBox(height: 10),
      _buildLatestDataButton('TEMPERATURE')
    ];
  }

  Widget _tracker2() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            ..._buildTrackerHeader('Heart Rate', 'hr'),
            if (_lastHr != null) ..._loadHrData(),
            if (_lastHr == null) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  List<Widget> _loadHrData() {
    return [
      Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Expanded(
            //   flex: 6,
            //   child: FittedBox(
            //     child:
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: _lastHr != null ? _lastHr.heartRate.toString() : '0',
                  style: TextStyle(
                    fontSize: 50,
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
            //   ),
            // ),
          ],
        ),
      ),
      _buildLastUpdatedTime(_lastHr.measureTime),
      const SizedBox(height: 10),
      _buildLatestDataButton('HR')
    ];
  }

  Widget _tracker3() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            ..._buildTrackerHeader('Blood Pressure', 'bp'),
            if (_bloodPressure != null) ..._loadBpData(),
            if (_bloodPressure == null) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  List<Widget> _loadBpData() {
    return [
      Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Expanded(
            //   flex: 6,
            //   child: FittedBox(
            //     child:
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: _bloodPressure != null
                      ? _bloodPressure.systolic.toString() +
                          '/' +
                          _bloodPressure.distolic.toString()
                      : '0/0',
                  style: TextStyle(
                    fontSize: 50,
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
            //   ),
            // ),
          ],
        ),
      ),
      _buildLastUpdatedTime(_bloodPressure.measureTime),
      const SizedBox(height: 10),
      _buildLatestDataButton('BP')
    ];
  }

  Widget _tracker4() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            ..._buildTrackerHeader('Oxygen Level', 'o2'),
            if (_oxygenLevel != null) ..._loadOxygenData(),
            if (_oxygenLevel == null) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  List<Widget> _loadOxygenData() {
    return [
      Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Expanded(
            //   flex: 6,
            //   child: FittedBox(
            //     child:
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: _oxygenLevel != null
                      ? _oxygenLevel.oxygenLevel.toString()
                      : '0',
                  style: TextStyle(
                    fontSize: 50,
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
            //   ),
            // ),
          ],
        ),
      ),
      _buildLastUpdatedTime(_oxygenLevel.measureTime),
      const SizedBox(height: 10),
      _buildLatestDataButton('O2')
    ];
  }

  Widget _tracker5() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            ..._buildTrackerHeader('Calories', 'calories'),
            if (_lastCalories != null) ..._buildCaloriesData(),
            if (_lastCalories == null) CircularProgressIndicator(),
            // _buildLatestDataButton('Calories')
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCaloriesData() {
    return [
      Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Expanded(
            //   flex: 6,
            //   child: FittedBox(
            //     child:
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _lastCalories != null
                        ? _lastCalories.calories.toString()
                        : '0',
                    style: TextStyle(
                      fontSize: 50,
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
              //   ),
              // ),
            ),
          ],
        ),
      ),
      _buildLastUpdatedTime(_lastCalories.measureTime),
      const SizedBox(height: 10),
    ];
  }

  Widget _tracker6() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: _cardDecoration(),
        child: Column(
          children: [
            ..._buildTrackerHeader('Steps', 'steps'),
            if (_lastSteps != null) ..._buildStepsData(),
            if (_lastSteps == null) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStepsData() {
    return [
      Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Expanded(
            //   flex: 6,
            //   child: FittedBox(
            //     child:
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text:
                      (_lastSteps != null ? _lastSteps.steps.toString() : '0'),
                  style: TextStyle(
                    fontSize: 50,
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
              //   ),
              // ),
            ),
          ],
        ),
      ),
      _buildLastUpdatedTime(_lastSteps.measureTime),
      const SizedBox(height: 10),
      // _buildLatestDataButton('steps')
    ];
  }

  List<Widget> _buildTrackerHeader(title, image) {
    return [
      Container(
        margin: EdgeInsets.only(
          top: 30,
          bottom: 10,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.all(16),
        child: SvgPicture.asset(
          'assets/trackers/' + image + '.svg',
          height: 150,
        ),
      ),
    ];
  }

  Widget _buildLastUpdatedTime(time) {
    return Container(
      child: FittedBox(
        child: Text(
          _lastSteps != null
              ? 'Last Updated: ' + _formatDate(time) + ' ' + _formatTime(time)
              : '--',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLatestDataButton(type) {
    return !canScroll
        ? Container(
            height: 0,
          )
        : Container(
            width: 250,
            height: 100,
            padding: EdgeInsets.all(15),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                // side: BorderSide(color: Colors.grey),
              ),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () {
                return _readDataFromDevice(type);
              },
              child: Text(
                'Get latest data',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          );
  }

  Widget _buildSlideDots(BuildContext context, bool isActive, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      // child: Center(
      //   child: FittedBox(
      //     child: Text(
      //       (index + 1).toString(),
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontSize: isActive ? 15 : 13,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          // spreadRadius: 5,
          blurRadius: 5,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFDBFBFF)],
      ),
    );
  }
}
