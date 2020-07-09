import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';

class SetupActiveScreen extends StatefulWidget {
  @override
  _SetupActiveScreenState createState() => _SetupActiveScreenState();
}

class _SetupActiveScreenState extends State<SetupActiveScreen> {
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];

  @override
  void initState() {
    _syncDataFromDevice().then((value) {});
    super.initState();
  }

  static const platform = const MethodChannel('ceras.iamhome.mobile/device');

  /**
   * Sync the data from the device
   */
  Future _syncDataFromDevice() async {
    final String result = await platform.invokeMethod('syncData');
    print("Got Sync Data "+result);
  }

  /**
   * Load the data from the device
   */
  Future _loadDataFromDevice() async {
    final String result = await platform.invokeMethod('loadData');
    print("Got load Data "+result);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 5,
          stopOnTerminate: false,
          enableHeadless: true,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresStorageNotLow: false,
          forceAlarmManager: true,// We are forcing alarm manager to make sure the task is prioritized in android
          requiresDeviceIdle: false,
          requiredNetworkType: NetworkType.NONE,
        ), (String taskId) async {
      switch (taskId) {
        case 'com.cerashealth.iamhome.datasync':
          _syncDataFromDevice();
          break;
        case 'com.cerashealth.iamhome.dataupdate':
          _loadDataFromDevice();
          print("Received custom update task");
          break;
        default:
          print("Default fetch task");
      }

      // This is the fetch-event callback.
      print("[BackgroundFetch] Event received $taskId");
      setState(() {
        _events.insert(0, new DateTime.now());
      });

      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    //Schedule the tasks
    _scheduleTask();

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  void _scheduleTask() {
    // Step 2:  Schedule a custom "oneshot" task "com.transistorsoft.datasync" to execute 5000ms from now.
    BackgroundFetch.scheduleTask(
      TaskConfig(
        taskId: "com.cerashealth.iamhome.datasync",
        delay: 5000, // <-- milliseconds
        periodic: true,
        startOnBoot: true,
        stopOnTerminate: false,
        enableHeadless: true
      ),
    );

    BackgroundFetch.scheduleTask(
      TaskConfig(
        taskId: "com.cerashealth.iamhome.dataupdate",
        delay: 10000, // <-- milliseconds
        periodic: true,
        startOnBoot: true,
        stopOnTerminate: false,
        enableHeadless: true
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(children: [
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          Expanded(
            child: Center(child: Text('')),
          )
        ]),
        actions: <Widget>[
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.headset_mic),
            onPressed: () {},
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxHeight: 300.0,
              ),
              padding: const EdgeInsets.all(10.0),
              child: FadeInImage(
                placeholder: AssetImage(
                  'assets/images/placeholder.jpg',
                ),
                image: AssetImage(
                  'assets/images/2.png',
                ),
                fit: BoxFit.contain,
                alignment: Alignment.center,
                fadeInDuration: Duration(milliseconds: 200),
                fadeInCurve: Curves.easeIn,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Device Found',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTheme.title,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                // vertical: 5.0,
                horizontal: 35.0,
              ),
              child: Text(
                'Last connected 04/24/2020  12:35 PM.',
                textAlign: TextAlign.center,
                style: AppTheme.subtitle,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              width: 150,
              height: 75,
              padding: EdgeInsets.all(10),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.5),
                ),
                color: Color(0XFF6C63FF),
                textColor: Colors.white,
                child: Text(
                  'SyncData',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
//                  return Navigator.of(context).pushReplacementNamed(
//                    routes.SetupHomeRoute,
//                  );
                  this._syncDataFromDevice();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
