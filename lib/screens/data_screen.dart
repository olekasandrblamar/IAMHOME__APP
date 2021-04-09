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

import '../theme.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> with WidgetsBindingObserver {
  final LocalAuthentication auth = LocalAuthentication();

  List<dynamic> trackerTypes = [];
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
      final deviceTrackers =
          await Provider.of<DevicesProvider>(context, listen: false)
              .getDeviceTrackers();

      print(deviceTrackers);

      setState(() {
        trackerTypeData = deviceTrackers;
      });
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
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'My Data',
        ),
        // actions: <Widget>[
        //   SwitchStoreIcon(),
        // ],
      ),
      backgroundColor: Color(0xffecf3fb),
      // body: Container(
      //   decoration: BoxDecoration(
      //     color: Color(0xffecf3fb),
      //   ),
      //   child: CustomScrollView(
      //     physics: BouncingScrollPhysics(),
      //     slivers: [
      //       SliverAppBar(
      //         // backgroundColor: Colors.transparent,
      //         // elevation: 0.0,
      //         pinned: true,
      //         expandedHeight: 150.0,
      //         stretch: true,
      //         stretchTriggerOffset: 75,
      //         flexibleSpace: FlexibleSpaceBar(
      //           title: Text(
      //             'My Data',
      //             style: TextStyle(
      //               fontSize: 25,
      //               // fontWeight: FontWeight.bold,
      //               // color: Colors.black,
      //             ),
      //           ),
      //           stretchModes: [
      //             StretchMode.zoomBackground,
      //             // StretchMode.blurBackground,
      //             // StretchMode.fadeTitle,
      //           ],
      //           background: Image.asset(
      //             'assets/images/clouds.png',
      //             fit: BoxFit.cover,
      //           ),
      //         ),
      //       ),
      //       SliverList(
      //         delegate: SliverChildListDelegate(
      //           []
      //         ),
      //       ),
      //     ],
      //   ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              ...trackerTypeData?.map((trackerMasterData) {
                    return TrackerDataWidget(
                        trackerMasterData: trackerMasterData);
                  }) ??
                  [],
              const SizedBox(height: 16),
            ],
          ),
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
  dynamic _trackerData;

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
        _trackerData = trackerDataMultiple;
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
            _trackerData != null
                ? Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        if (trackerMasterData.graphType == 'SINGLE_LINE_GRAPH')
                          singleDisplayText(trackerMasterData, _trackerData),
                        if (trackerMasterData.graphType ==
                            'MULTIPLE_LINE_GRAPH')
                          multipleDisplayText(trackerMasterData, _trackerData),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
            _trackerData != null
                ? lastUpdated(_trackerData)
                : Container(
                    height: 0,
                  ),
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
            'assets/icons/icons_' +
                trackerMasterData?.trackerName?.toLowerCase() +
                '.png',
            height: 25,
            errorBuilder: (
              BuildContext context,
              Object exception,
              StackTrace stackTrace,
            ) {
              return Image.asset(
                'assets/images/placeholder.jpg',
                height: 25,
              );
            },
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
  String trackerDataValue1;
  String trackerDataValue2;

  if (_trackerData.data1 != null && _trackerData.data2 != null) {
    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'INTEGER') {
      trackerDataValue1 = _trackerData?.data1?.toInt().toString();
    }

    if (trackerMasterData?.trackerValues[1]?.valueDataType == 'INTEGER') {
      trackerDataValue2 = _trackerData?.data2?.toInt().toString();
    }

    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'DOUBLE') {
      trackerDataValue1 = _trackerData?.data1?.toStringAsFixed(1);
    }

    if (trackerMasterData?.trackerValues[1]?.valueDataType == 'DOUBLE') {
      trackerDataValue2 = _trackerData?.data2?.toStringAsFixed(1);
    }

    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'STRING') {
      trackerDataValue1 = _trackerData?.data1.toString();
    }

    if (trackerMasterData?.trackerValues[1]?.valueDataType == 'STRING') {
      trackerDataValue1 = _trackerData?.data2.toString();
    }
  } else {
    trackerDataValue1 = '0';
    trackerDataValue2 = '0';
  }

  return Expanded(
    flex: 6,
    child: FittedBox(
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: trackerDataValue1 + '/' + trackerDataValue2,
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
  String trackerDataValue;

  if (_trackerData != null) {
    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'INTEGER') {
      trackerDataValue = _trackerData?.data?.toInt().toString();
    }

    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'DOUBLE') {
      trackerDataValue = _trackerData?.data?.toStringAsFixed(1);
    }

    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'STRING') {
      trackerDataValue = _trackerData?.data.toString();
    }
  } else {
    trackerDataValue = '0';
  }

  return Expanded(
    flex: 6,
    child: FittedBox(
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: trackerDataValue,
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
