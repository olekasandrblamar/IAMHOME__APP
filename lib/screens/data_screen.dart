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

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> with WidgetsBindingObserver {
  var currentPageValue = 0.0;
  int _currentPage = 0;
  var trackers = [1, 2, 3, 4, 5, 6];

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
                  Expanded(
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: trackers.length,
                      itemBuilder: (ctx, i) => Transform(
                        transform: Matrix4.identity()
                          ..rotateX(currentPageValue - i),
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
                      physics: NeverScrollableScrollPhysics(),
                    ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tracker1() {
    return Container(
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
                                ? _lastTemperature.fahrenheit.toStringAsFixed(1)
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
                          _formatDate(_lastTemperature.measureTime) +
                          ' ' +
                          _formatTime(_lastTemperature.measureTime)
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
    );
  }

  Widget _tracker2() {
    return Container(
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
    );
  }

  Widget _tracker3() {
    return Container(
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
                                ? _bloodPressure.systolic.toString() +
                                    '/' +
                                    _bloodPressure.distolic.toString()
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
                          _formatDate(_bloodPressure.measureTime) +
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
    );
  }

  Widget _tracker4() {
    return Container(
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
                                ? _oxygenLevel.oxygenLevel.toString()
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
                  _bloodPressure != null
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
    );
  }

  Widget _tracker5() {
    return Container(
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
                                  ? _lastCalories.calories.toString()
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
    );
  }

  Widget _tracker6() {
    return Container(
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
}
