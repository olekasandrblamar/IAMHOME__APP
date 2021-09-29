import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/models/tracker_model.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:circular_countdown/circular_countdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import 'dart:io';
import 'dart:convert';

import '../theme.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> with WidgetsBindingObserver {
  var currentPageValue = 0.0;
  int _currentPage = 0;

  bool canScroll = true;

  final PageController _pageController = PageController(
    initialPage: 0,
    // viewportFraction: 0.8,
  );

  final LocalAuthentication auth = LocalAuthentication();

  List<dynamic> trackerTypes = [];
  List<Tracker> trackerTypeData = [];

  Map<String, bool> processingMap = {};

  final eventChannel = EventChannel("ceras.iamhome.mobile/device_events");

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('Got state ${state}');
    switch (state) {
      case AppLifecycleState.resumed:
        // if (!Platform.isIOS) {
        //   _goToLogin();
        // }
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

  // void _readDataFromDevice(String dataType) async {
  //   setState(() {
  //     canScroll = false;
  //   });
  //   print('Loading data type $dataType');
  //   var _processingMap = processingMap;
  //   _processingMap[dataType] = true;
  //   setState(() {
  //     processingMap = _processingMap;
  //   });
  //   var deviceList = await Provider.of<DevicesProvider>(context, listen: false)
  //       .getDevicesData();
  //   var device = deviceList[0];
  //   final requestData = {
  //     'deviceType': device.watchInfo.deviceType,
  //     'readingType': dataType
  //   };
  //   var request = json.encode(requestData);
  //   //var currentTemp = _lastTemperature;
  //   print('Sending request $request');
  //   switch (dataType) {
  //     case 'TEMPERATURE':
  //       {
  //         setState(() {
  //           _lastTemperature = null;
  //         });
  //       }
  //       break;
  //     case 'HR':
  //       {
  //         setState(() {
  //           _lastHr = null;
  //         });
  //       }
  //       break;
  //     case 'O2':
  //       {
  //         setState(() {
  //           _oxygenLevel = null;
  //         });
  //       }
  //       break;
  //     case 'BP':
  //       {
  //         setState(() {
  //           _bloodPressure = null;
  //         });
  //       }
  //       break;
  //     default:
  //       {}
  //       break;
  //   }
  //
  //   var subscription =
  //   eventChannel.receiveBroadcastStream(requestData).listen((event) {
  //     final returnData = json.decode(event);
  //     switch (dataType) {
  //       case 'TEMPERATURE':
  //         {
  //           if (returnData['countDown'] == 0) {
  //             var updatedTemp = Temperature();
  //             updatedTemp.celsius = returnData['celsius'];
  //             updatedTemp.fahrenheit = returnData['fahrenheit'];
  //             updatedTemp.measureTime = DateTime.now();
  //             setState(() {
  //               _lastTemperature = updatedTemp;
  //             });
  //           }
  //         }
  //         break;
  //       case 'HR':
  //         {
  //           if (returnData['rate'] != 0) {
  //             var updatedHr = HeartRate();
  //             updatedHr.heartRate = returnData['heartRate'];
  //             updatedHr.measureTime = DateTime.now();
  //             setState(() {
  //               _lastHr = updatedHr;
  //             });
  //           }
  //         }
  //         break;
  //       case 'BP':
  //         {
  //           if (returnData['systolic'] != 0) {
  //             var updatedBp = BloodPressure();
  //             updatedBp.systolic = returnData['systolic'];
  //             updatedBp.distolic = returnData['diastolic'];
  //             updatedBp.measureTime = DateTime.now();
  //             setState(() {
  //               _bloodPressure = updatedBp;
  //             });
  //           }
  //         }
  //         break;
  //       case 'O2':
  //         {
  //           if (returnData['oxygenLevel'] != 0) {
  //             var updateo2 = OxygenLevel();
  //             updateo2.oxygenLevel = returnData['oxygenLevel'];
  //             updateo2.measureTime = DateTime.now();
  //             setState(() {
  //               _oxygenLevel = updateo2;
  //             });
  //           }
  //         }
  //         break;
  //       default:
  //         {}
  //         break;
  //     }
  //   }, onError: (dynamic error) {
  //     var _processingMap = processingMap;
  //     _processingMap[dataType] = false;
  //     setState(() {
  //       processingMap = _processingMap;
  //       canScroll = true;
  //     });
  //     _currentCountDown = null;
  //     print('Got error $error for data type $dataType');
  //   }, onDone: () {
  //     print('completed for $dataType');
  //     var _processingMap = processingMap;
  //     _processingMap[dataType] = false;
  //     setState(() {
  //       canScroll = true;
  //       _currentCountDown = null;
  //       processingMap = _processingMap;
  //     });
  //   }, cancelOnError: true);
  // }

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
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          // child: Column(
          //   children: [
          //     const SizedBox(height: 16),
          //     ...trackerTypeData?.map((trackerMasterData) {
          //           return TrackerDataWidget(
          //               trackerMasterData: trackerMasterData);
          //         }) ??
          //         [],
          //     const SizedBox(height: 16),
          //   ],
          // ),

          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            // ),
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
                    itemCount: trackerTypeData.length,
                    itemBuilder: (ctx, i) => Transform(
                      transform: Matrix4.identity()
                        ..rotateX(currentPageValue - i),
                      child: TrackerDataWidget(
                        trackerMasterData: trackerTypeData[i],
                      ),
                    ),
                    physics: canScroll
                        ? ScrollPhysics()
                        : NeverScrollableScrollPhysics(),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                _populateDots(),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _populateDots() {
    if (canScroll) {
      return Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < trackerTypeData.length; i++)
              if (i == _currentPage)
                _buildSlideDots(context, true, i)
              else
                _buildSlideDots(context, false, i)
          ],
        ),
      );
    } else {
      return SizedBox(height: 25);
    }
  }

  Widget _buildSlideDots(BuildContext context, bool isActive, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: isActive ? 20 : 12,
      width: isActive ? 20 : 12,
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

  bool canScroll = true;

  bool _paused = false;

  Map<String, bool> processingMap = {};

  final eventChannel = EventChannel("ceras.iamhome.mobile/device_events");

  TimeCircularCountdown _currentCountDown;

  @override
  void initState() {
    // _loadData();

    // TODO: implement initState
    super.initState();
  }

  Future<void> _loadData() async {
    if (trackerMasterData.trackerType == 'DOUBLE_VALUE') {
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

  void _readDataFromDevice(String dataType) async {
    setState(() {
      canScroll = false;
    });
    print('Loading data type $dataType');
    var _processingMap = processingMap;
    _processingMap[dataType] = true;
    setState(() {
      processingMap = _processingMap;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    //   child: Card(
    //     // color: Color(0xffdfeffd),
    //     elevation: 5,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(20.0),
    //     ),
    //     child: Column(
    //       children: [
    //         trackerDisplayName(trackerMasterData),
    //         _trackerData != null
    //             ? Container(
    //                 padding: EdgeInsets.all(16),
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: <Widget>[
    //                     if (trackerMasterData.trackerType == 'SINGLE_VALUE')
    //                       singleDisplayText(trackerMasterData, _trackerData),
    //                     if (trackerMasterData.trackerType == 'DOUBLE_VALUE')
    //                       multipleDisplayText(trackerMasterData, _trackerData),
    //                   ],
    //                 ),
    //               )
    //             : Padding(
    //                 padding: const EdgeInsets.all(16.0),
    //                 child: CircularProgressIndicator(),
    //               ),
    //         _trackerData != null
    //             ? lastUpdated(_trackerData)
    //             : Container(
    //                 height: 0,
    //               ),
    //         const SizedBox(height: 10),
    //       ],
    //     ),
    //   ),
    // );

    return Container(
      padding: _trackerPadding(),
      child: Container(
        decoration: _cardDecoration(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ..._buildTrackerHeader(trackerMasterData),
              // if (_lastTemperature != null) ..._loadTemperatureData(),
              // if (_lastTemperature == null)
              //   _loadCountDownTimer(70, 'Temperature'),
              // _buildLatestDataButton('O2', 'Oxygen Saturation'),
              // const SizedBox(height: 10),
              // _buildLastUpdatedTime(_oxygenLevel.measureTime)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestDataButton(type, displayName) {
    return !canScroll
        ? _loadCircularIndicator(displayName)
        : Container(
            width: 270,
            height: 80,
            padding: EdgeInsets.all(15),
            child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  // side: BorderSide(color: Colors.grey),
                ),
                color: Color.fromRGBO(11, 140, 196, 1),
                textColor: Colors.white,
                onPressed: () {
                  return _readDataFromDevice(type);
                },
                child: FittedBox(
                  child: Text(
                    'Measure Now',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                )),
          );
  }

  List<Widget> _buildTrackerHeader(trackerMasterData) {
    return [
      Container(
        margin: EdgeInsets.only(
          top: 30,
          bottom: 10,
        ),
        child: Text(
          trackerMasterData?.displayName,
          style: TextStyle(
            fontSize: 26,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.width * 0.1,
      ),

      // Image.asset(
      //   'assets/icons/icons_' +
      //       trackerMasterData?.trackerName?.toLowerCase() +
      //       '.png',
      //   height: 25,
      //   errorBuilder: (
      //     BuildContext context,
      //     Object exception,
      //     StackTrace stackTrace,
      //   ) {
      //     return Image.asset(
      //       'assets/images/placeholder.jpg',
      //       height: 25,
      //     );
      //   },
      // ),

      Container(
        padding: EdgeInsets.all(16),
        child: SvgPicture.asset(
          'assets/trackers/' +
              trackerMasterData?.trackerName?.toLowerCase() +
              '.svg',
          height: MediaQuery.of(context).size.width * 0.2,
        ),
      ),
      SizedBox(height: 20),
    ];
  }

  Widget _buildLastUpdatedTime(time) {
    return Container(
      child: FittedBox(
        child: Text(
          'Last: ' + _formatDate(time) + ' ' + _formatTime(time),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _loadCountDownTimer(int seconds, String type) {
    _currentCountDown = TimeCircularCountdown(
      unit: CountdownUnit.second,
      countdownTotal: seconds,
      onUpdated: (unit, remainingTime) => print('Updated'),
      onFinished: () {
        if (_currentCountDown != null) {
          setState(() {
            canScroll = false;
          });
        }
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
    );
    var buttonText = canScroll ? 'Loading $type ...' : 'Reading $type ...';
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 100),
        canScroll
            ?
            // TimeCircularCountdown(
            //   unit: CountdownUnit.second,
            //   countdownTotal: 10,
            //   diameter: 200,
            //   countdownTotalColor: Colors.white,
            //   countdownCurrentColor: Colors.blue,
            //   countdownRemainingColor: Colors.blue,
            //   strokeWidth: 20,
            //   gapFactor: 5,
            //   repeat: true,
            //   onUpdated: (unit, remainingTime) => print('Updated'),
            // // textStyle: TextStyle(
            // // fontSize: 50,
            // // fontWeight: FontWeight.bold,
            // // color: Colors.redAccent,
            // // ),
            // )
            Container()
            : _currentCountDown,
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(buttonText,
                  style: TextStyle(fontSize: 20, color: Colors.black)),
            )
          ],
        ),
      ],
    );
  }
}

EdgeInsets _trackerPadding() {
  return EdgeInsets.symmetric(horizontal: 40, vertical: 5);
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
    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'INT') {
      trackerDataValue1 = _trackerData?.data1?.toInt().toString();
    }

    if (trackerMasterData?.trackerValues[1]?.valueDataType == 'INT') {
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

  if (_trackerData.data != null) {
    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'INT') {
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
                trackerMasterData?.trackerValues[0].units ?? '',
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

Widget _loadCircularIndicator(String text) {
  return Column(
    children: [
      SizedBox(height: 10),
      CircularProgressIndicator(),
      SizedBox(height: 20),
      Text('Reading ' + text,
          style: TextStyle(fontSize: 20, color: Colors.black))
    ],
  );
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.70), BlendMode.dstATop),
          image: AssetImage('assets/trackers/tracker_background.png'),
          fit: BoxFit.fill)
      // boxShadow: [
      //   BoxShadow(
      //     color: Colors.grey.withOpacity(0.5),
      //     // spreadRadius: 5,
      //     blurRadius: 5,
      //     offset: Offset(0, 3), // changes position of shadow
      //   ),
      // ],
      // gradient: LinearGradient(
      //   begin: Alignment.topCenter,
      //   end: Alignment.bottomCenter,
      //   colors: [Color(0xFFFFFFFF), Color(0xFFDBFBFF)],
      // ),
      );
}

String _formatDate(DateTime date) {
  return DateFormat.MMMMd().format(date.toLocal());
}

String _formatTime(DateTime date) {
  return DateFormat.jm().format(date.toLocal());
}
