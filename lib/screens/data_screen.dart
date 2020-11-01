import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/models/trackers/tracker_data_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  Temperature _lastTemperature = null;

  HeartRate _lastHr = null;

  BloodPressure _bloodPressure = null;

  Calories _lastCalories = null;

  DailySteps _lastSteps = null;

  @override
  void initState() {
    _initData();

    // TODO: implement initState
    super.initState();
  }

  Future<void> _initData() async {
    //This code is to refresh the acccess token
    final accessToken = await Provider.of<AuthProvider>(context, listen: false).authToken;
    if(accessToken!=null) {
      _loadTemperature();
      _loadBloodPressure();
      _loadHeartRate();
      _loadCalories();
      _loadSteps();
    }else{
      //Send to login screen
    }
  }

  String _formatDate(DateTime date){
    return DateFormat.yMMMMd().format(date.toLocal());
  }

  String _formatTime(DateTime date){
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
                  // style: TextStyle(
                  //   fontSize: 30,
                  //   fontWeight: FontWeight.bold,
                  //   color: Colors.black,
                  // ),
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
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
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
                                              ? _lastTemperature.fahrenheit.toStringAsFixed(2)
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
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_lastTemperature != null
                                          ? _formatDate(_lastTemperature.measureTime)
                                          : ''),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_lastTemperature != null
                                          ? _formatTime(_lastTemperature.measureTime)
                                          : ''),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
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
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
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
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_lastHr != null
                                          ? _formatDate(_lastHr.measureTime)
                                          : ''),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_lastHr != null
                                          ? _formatTime(_lastHr.measureTime)
                                          : ''),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
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
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
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
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_bloodPressure != null
                                          ? _formatDate(_bloodPressure.measureTime)
                                          : ''),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_bloodPressure != null
                                          ? _formatTime(_bloodPressure.measureTime)
                                          : ''),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
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
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
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
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_lastCalories != null
                                          ? _formatDate(_lastCalories.measureTime)
                                          : ''),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_lastCalories != null
                                          ? _formatTime(_lastCalories.measureTime)
                                          : ''),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
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
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
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
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_lastSteps != null
                                          ? _formatDate(_lastSteps.measureTime)
                                          : ''),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(_lastSteps != null
                                          ? _formatTime(_lastSteps.measureTime)
                                          : ''),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
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
