import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/models/tracker_model.dart';
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
  final LocalAuthentication auth = LocalAuthentication();

  List<dynamic> trackerTypes = [
    {
      'id': 1,
      'displayName': 'BP',
      'trackerName': 'bloodpressure',
      'trackerType': 'SINGLE_VALUE',
      'graphType': 'MULTIPLE_LINE_GRAPH',
      'trackerValues': [
        {
          'id': 9,
          'displayName': 'Systolic',
          'valueName': 'Systolic',
          'baseLineMin': 115.0,
          'baseLineMax': 115.0,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': '',
          'offset': 0.0,
          'unitsDisplayName': '',
          'severities': [
            {'id': 12, 'minValue': 50.0, 'maxValue': 100.0, 'severity': 2},
            {'id': 10, 'minValue': 70.0, 'maxValue': 80.0, 'severity': 0},
            {'id': 11, 'minValue': 60.0, 'maxValue': 90.0, 'severity': 1}
          ],
          'order': 1,
          'dataPropertyName': 'systolic'
        },
        {
          'id': 10,
          'displayName': 'Distolic',
          'valueName': 'Distolic',
          'baseLineMin': 65.0,
          'baseLineMax': 65.0,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': '',
          'offset': 0.0,
          'unitsDisplayName': '',
          'severities': [
            {'id': 13, 'minValue': 100.0, 'maxValue': 140.0, 'severity': 0},
            {'id': 15, 'minValue': 80.0, 'maxValue': 160.0, 'severity': 2},
            {'id': 14, 'minValue': 90.0, 'maxValue': 150.0, 'severity': 1}
          ],
          'order': 2,
          'dataPropertyName': 'distolic'
        }
      ],
      'deleted': false,
      'active': true
    },
    {
      'id': 2,
      'displayName': 'Steps',
      'trackerName': 'steps',
      'trackerType': 'SINGLE_VALUE',
      'graphType': 'SINGLE_LINE_GRAPH',
      'trackerValues': [
        {
          'id': 6,
          'displayName': 'Steps',
          'valueName': '',
          'baseLineMin': 100.0,
          'baseLineMax': 100.0,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': 'steps',
          'offset': 0.0,
          'unitsDisplayName': 'steps',
          'severities': [
            {'id': 22, 'minValue': 100.0, 'maxValue': 200.0, 'severity': 0},
            {'id': 23, 'minValue': 50.0, 'maxValue': 200.0, 'severity': 1},
            {'id': 24, 'minValue': 5.0, 'maxValue': 200.0, 'severity': 2}
          ],
          'order': 1,
          'dataPropertyName': 'steps'
        }
      ],
      'deleted': false,
      'active': true
    },
    {
      'id': 3,
      'displayName': 'Daily Steps',
      'trackerName': 'dailySteps',
      'trackerType': 'SINGLE_VALUE',
      'graphType': 'SINGLE_LINE_GRAPH',
      'trackerValues': [
        {
          'id': 5,
          'displayName': 'Steps',
          'valueName': '',
          'baseLineMin': 1000.0,
          'baseLineMax': 1000.0,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': 'steps',
          'offset': 0.0,
          'unitsDisplayName': 'steps',
          'severities': [
            {'id': 19, 'minValue': 100.0, 'maxValue': 200.0, 'severity': 0},
            {'id': 20, 'minValue': 50.0, 'maxValue': 200.0, 'severity': 1},
            {'id': 21, 'minValue': 5.0, 'maxValue': 200.0, 'severity': 2}
          ],
          'order': 1,
          'dataPropertyName': 'steps'
        }
      ],
      'deleted': false,
      'active': true
    },
    {
      'id': 5,
      'displayName': 'Blood Oxygen',
      'trackerName': 'bloodOxygen',
      'trackerType': 'SINGLE_VALUE',
      'graphType': 'SINGLE_LINE_GRAPH',
      'trackerValues': [
        {
          'id': 7,
          'displayName': 'Percentage',
          'valueName': 'Percentage',
          'baseLineMin': 95.0,
          'baseLineMax': 95.0,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': '%',
          'offset': 0.0,
          'unitsDisplayName': '%',
          'severities': [
            {'id': 28, 'minValue': 96.0, 'maxValue': 100.0, 'severity': 0},
            {'id': 29, 'minValue': 95.0, 'maxValue': 101.0, 'severity': 1},
            {'id': 30, 'minValue': 94.0, 'maxValue': 102.0, 'severity': 2}
          ],
          'order': 1,
          'dataPropertyName': 'oxygenLevel'
        }
      ],
      'deleted': false,
      'active': true
    },
    {
      'id': 6,
      'displayName': 'Temperature',
      'trackerName': 'temperature',
      'trackerType': 'SINGLE_VALUE',
      'graphType': 'SINGLE_LINE_GRAPH',
      'trackerValues': [
        {
          'id': 1,
          'displayName': 'Fahrenheit',
          'valueName': 'Fahrenheit',
          'baseLineMin': 96.5,
          'baseLineMax': 96.5,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': '°F',
          'offset': 0.0,
          'unitsDisplayName': 'Fahrenheit',
          'severities': [
            {'id': 1, 'minValue': 96.0, 'maxValue': 99.0, 'severity': 0},
            {'id': 2, 'minValue': 94.0, 'maxValue': 101.0, 'severity': 1},
            {'id': 3, 'minValue': 90.0, 'maxValue': 103.0, 'severity': 2}
          ],
          'order': 1,
          'dataPropertyName': 'fahrenheit'
        },
        {
          'id': 2,
          'displayName': 'Celsius',
          'valueName': 'Celsius',
          'baseLineMin': 36.1,
          'baseLineMax': 36.1,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': '°C',
          'offset': 0.0,
          'unitsDisplayName': 'Celsius',
          'severities': [
            {'id': 5, 'minValue': 34.0, 'maxValue': 38.0, 'severity': 1},
            {'id': 6, 'minValue': 32.0, 'maxValue': 40.0, 'severity': 2},
            {'id': 4, 'minValue': 35.0, 'maxValue': 37.0, 'severity': 0}
          ],
          'order': 1,
          'dataPropertyName': 'celsius'
        }
      ],
      'deleted': false,
      'active': true
    },
    {
      'id': 7,
      'displayName': 'Heart Rate',
      'trackerName': 'heartrate',
      'trackerType': 'SINGLE_VALUE',
      'graphType': 'SINGLE_LINE_GRAPH',
      'trackerValues': [
        {
          'id': 3,
          'displayName': 'Beats/Min',
          'valueName': 'Beats/Min',
          'baseLineMin': 60.0,
          'baseLineMax': 60.0,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': 'BPM',
          'offset': 0.0,
          'unitsDisplayName': 'BPM',
          'severities': [
            {'id': 7, 'minValue': 65.0, 'maxValue': 110.0, 'severity': 0},
            {'id': 9, 'minValue': 55.0, 'maxValue': 160.0, 'severity': 2},
            {'id': 8, 'minValue': 60.0, 'maxValue': 130.0, 'severity': 1}
          ],
          'order': 1,
          'dataPropertyName': 'heartRate'
        }
      ],
      'deleted': false,
      'active': true
    },
    {
      'id': 8,
      'displayName': 'Calories',
      'trackerName': 'calories',
      'trackerType': 'SINGLE_VALUE',
      'graphType': 'SINGLE_LINE_GRAPH',
      'trackerValues': [
        {
          'id': 4,
          'displayName': 'Calories',
          'valueName': 'Calories',
          'baseLineMin': 2500.0,
          'baseLineMax': 2500.0,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': 'KCal',
          'offset': 0.0,
          'unitsDisplayName': 'KCal',
          'severities': [
            {'id': 18, 'minValue': 5.0, 'maxValue': 200.0, 'severity': 2},
            {'id': 16, 'minValue': 15.0, 'maxValue': 200.0, 'severity': 0},
            {'id': 17, 'minValue': 10.0, 'maxValue': 200.0, 'severity': 1}
          ],
          'order': 1,
          'dataPropertyName': 'calories'
        }
      ],
      'deleted': false,
      'active': true
    },
    {
      'id': 4,
      'displayName': 'Sleep',
      'trackerName': 'sleep',
      'trackerType': 'SINGLE_VALUE',
      'graphType': 'SINGLE_LINE_GRAPH',
      'trackerValues': [
        {
          'id': 8,
          'displayName': 'Hours',
          'valueName': 'Hours',
          'baseLineMin': 5.0,
          'baseLineMax': 14.0,
          'minValue': 0.0,
          'maxValue': 200.0,
          'baseSeverity': 0,
          'units': 'Hrs',
          'offset': null,
          'unitsDisplayName': 'Hrs',
          'severities': [
            {'id': 26, 'minValue': 15.0, 'maxValue': 4.0, 'severity': 1},
            {'id': 25, 'minValue': 12.0, 'maxValue': 6.0, 'severity': 0},
            {'id': 27, 'minValue': 18.0, 'maxValue': 2.0, 'severity': 2}
          ],
          'order': 1,
          'dataPropertyName': null
        }
      ],
      'deleted': false,
      'active': true
    }
  ];
  List<Tracker> trackerTypeData = [];

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
      final formattedData = <Tracker>[];
      trackerTypes.forEach(
        (data) {
          formattedData.add(
            Tracker.fromJson(data),
          );
        },
      );

      trackerTypeData = formattedData;
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
                  ...trackerTypeData.map(
                    (trackerMasterData) {
                      return TrackerDataWidget(
                          trackerMasterData: trackerMasterData);
                    },
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

class TrackerDataWidget extends StatefulWidget {
  final Tracker trackerMasterData;

  const TrackerDataWidget({
    @required this.trackerMasterData,
  });

  @override
  _TrackerDataWidgetState createState() =>
      _TrackerDataWidgetState(trackerMasterData);
}

class _TrackerDataWidgetState extends State<TrackerDataWidget> {
  _TrackerDataWidgetState(this.trackerMasterData);

  final Tracker trackerMasterData;
  TrackerData _trackerData;
  TrackerDataMultiple _trackerDataMultiple;

  @override
  void initState() {
    _loadData();

    // TODO: implement initState
    super.initState();
  }

  Future<void> _loadData() async {
    if (trackerMasterData.graphType == 'MULTIPLE_LINE_GRAPH') {
      var trackerDataMultiple =
          await Provider.of<DevicesProvider>(context, listen: false)
              .getLatestTrackerMultipleData(trackerMasterData);

      setState(() {
        _trackerDataMultiple = trackerDataMultiple;
      });
    } else {
      var trackerData =
          await Provider.of<DevicesProvider>(context, listen: false)
              .getLatestTrackerData(trackerMasterData);

      setState(() {
        _trackerData = trackerData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            trackerDisplayName(trackerMasterData),
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  singleDisplayText(trackerMasterData, _trackerData)
                ],
              ),
            ),
            if (trackerMasterData.graphType == 'SINGLE_LINE_GRAPH')
              lastUpdated(_trackerData),
            if (trackerMasterData.graphType == 'MULTIPLE_LINE_GRAPH')
              lastUpdated(_trackerDataMultiple),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

Container trackerDisplayName(trackerMasterData) {
  return Container(
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
            trackerMasterData?.displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Container lastUpdated(_trackerData) {
  String _formatDate(DateTime date) {
    return DateFormat.yMMMMd().format(date.toLocal());
  }

  String _formatTime(DateTime date) {
    return DateFormat.jm().format(date.toLocal());
  }

  return Container(
    child: FittedBox(
      child: Text(
        _trackerData != null
            ? 'Last Updated: ' +
                _formatDate(_trackerData.measureTime) +
                ' ' +
                _formatTime(_trackerData.measureTime)
            : '--',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Expanded multipleDisplayText(trackerMasterData, _trackerData) {
  return Expanded(
    flex: 6,
    child: FittedBox(
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: _trackerData.data1 != null
                ? _trackerData.data1.toString() +
                    '/' +
                    _trackerData.data2.toString()
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
                trackerMasterData?.trackerValues[0].units,
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
  );
}

Expanded singleDisplayText(trackerMasterData, _trackerData) {
  return Expanded(
    flex: 6,
    child: FittedBox(
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: (_trackerData != null ? _trackerData.data.toString() : '0'),
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
                trackerMasterData?.trackerValues[0].units,
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
  );
}
