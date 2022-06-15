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

  void updateScroll(bool _canScroll){
    setState(() {
      canScroll = _canScroll;
    });
    print('Got can scroll $canScroll');
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
      ),
      backgroundColor: Color(0xffecf3fb),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
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
                        updateScroll: updateScroll,
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
    );
  }
}

class TrackerDataWidget extends StatefulWidget {
  final Tracker trackerMasterData;
  final updateScroll;

  const TrackerDataWidget({
    @required this.trackerMasterData,
    @required this.updateScroll
  });

  @override
  _TrackerDataWidgetState createState() =>
      _TrackerDataWidgetState(trackerMasterData,updateScroll);
}

class _TrackerDataWidgetState extends State<TrackerDataWidget> {
  _TrackerDataWidgetState(this.trackerMasterData,this.updateScroll);

  final Tracker trackerMasterData;
  final updateScroll;
  dynamic _trackerData;

  bool canScroll = true;
  bool canShow = true;

  bool _paused = false;

  Map<String, bool> processingMap = {};

  final eventChannel = EventChannel("ceras.iamhome.mobile/device_events");

  TimeCircularCountdown _currentCountDown;

  @override
  void initState() {
    _loadData();

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

  void updateCanScroll(bool _canScroll){
    updateScroll(_canScroll);
    canScroll = _canScroll;
    canShow = _canScroll;
    setState(() {
      canScroll = _canScroll;
      canShow = _canScroll;
    });
  }

  void _readDataFromDevice(String dataType) async {
    updateCanScroll(false);
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

    setState(() {
      _trackerData = null;
    });

    var subscription =
        eventChannel.receiveBroadcastStream(requestData).listen((event) {
          dynamic returnData;
          if(trackerMasterData.trackerType == 'DOUBLE_VALUE') {
            returnData = TrackerDataMultiple.fromJson(json.decode(event));
          } else {
            returnData = TrackerData.fromJson(json.decode(event));
          }
      setState(() {
        _trackerData = returnData;
        canShow = true;
      });
    }, onError: (dynamic error) {
      var _processingMap = processingMap;
      _processingMap[dataType] = false;
      updateCanScroll(true);
      setState(() {
        processingMap = _processingMap;
      });
      _currentCountDown = null;
      print('Got error $error for data type $dataType');
    }, onDone: () {
      print('completed for $dataType');
      var _processingMap = processingMap;
      _processingMap[dataType] = false;
      updateCanScroll(true);
      setState(() {
        _currentCountDown = null;
        processingMap = _processingMap;
      });
    }, cancelOnError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _trackerPadding(),
      child: Container(
        decoration: _cardDecoration(),
        child: SingleChildScrollView(
          child: Column(
            children:
              !canShow?[_loadCountDownTimer(60, trackerMasterData.displayName)]:[
              ..._buildTrackerHeader(trackerMasterData, context),
              if (trackerMasterData.trackerType == 'SINGLE_VALUE' &&
                  _trackerData != null)
                ...singleDisplayText(trackerMasterData, _trackerData),
              if (trackerMasterData.trackerType == 'DOUBLE_VALUE' &&
                  _trackerData != null)
                ...multipleDisplayText(trackerMasterData, _trackerData),
              const SizedBox(height: 10),
              _buildLatestDataButton(trackerMasterData),
              const SizedBox(height: 10),
              _trackerData != null
                  ? _buildLastUpdatedTime(_trackerData)
                  : Container(
                      height: 0,
                    ),
              const SizedBox(height: 10),
              // if (_trackerData == null)
              //   _loadCountDownTimer(70, trackerMasterData?.displayName),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildLatestDataButton(Tracker trackerMasterData) {
    //If the measure now is enabled
    if(trackerMasterData.mobileMeasureNow) {
      return !canScroll
          ? _loadCircularIndicator(trackerMasterData?.displayName)
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
            return _readDataFromDevice(trackerMasterData?.displayName);
          },
          child: FittedBox(
            child: Text(
              'Measure Now',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      );
    }else {
      return Container();
    }
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
        canScroll ? Container() : _currentCountDown,
        SizedBox(height: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildTrackerLoadingFooter(trackerMasterData, context),
          // children: [
          //   // FittedBox(
          //   //   child: Text(buttonText,
          //   //       style: TextStyle(fontSize: 20, color: Colors.black)),
          //   // ),
          //   Container(
          //     child:
          //         Column(
          //   children: _buildTrackerHeader(trackerMasterData, context),
          //   )
          //
          //   )
          // ],
        ),
      ],
    );
  }
}

EdgeInsets _trackerPadding() {
  return EdgeInsets.symmetric(horizontal: 40, vertical: 5);
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
      colorFilter:
          ColorFilter.mode(Colors.white.withOpacity(0.70), BlendMode.dstATop),
      image: AssetImage('assets/trackers/tracker_background.png'),
      fit: BoxFit.fill,
    ),
  );
}

List<Widget> multipleDisplayText(Tracker trackerMasterData, _trackerData) {
  var trackerDataValue1 = '0';
  var trackerDataValue2 = '0';

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
  }

  return [
    Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: trackerDataValue1 + '/' + trackerDataValue2,
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
              ],
            ),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> singleDisplayText(Tracker trackerMasterData, _trackerData) {
  var trackerDataValue = '0';

  if (_trackerData?.data != null) {
    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'INT') {
      trackerDataValue = _trackerData?.data?.toInt().toString();
    }

    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'DOUBLE') {
      trackerDataValue = _trackerData?.data?.toStringAsFixed(1);
    }

    if (trackerMasterData?.trackerValues[0]?.valueDataType == 'STRING') {
      trackerDataValue = _trackerData?.data.toString();
    }
  }

  return [
    Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: trackerDataValue,
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
        ],
      ),
    ),
  ];
}

List<Widget> _buildTrackerLoadingFooter(Tracker trackerMasterData, context) {
  return [
    Container(
      margin: EdgeInsets.only(
        top: 10,
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
    Container(
      padding: EdgeInsets.only(
      top: 30
  ),
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

List<Widget> _buildTrackerHeader(Tracker trackerMasterData, context) {
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

Container _buildLastUpdatedTime(_trackerData) {
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
