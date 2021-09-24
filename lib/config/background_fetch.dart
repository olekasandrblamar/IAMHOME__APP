//import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundFetchData {
  static const platform = MethodChannel('ceras.iamhome.mobile/device');
}

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');

  switch (taskId) {
    case 'com.transistorsoft.datasync':
      print("Calling data sync");
      await syncDataFromDevice();
      break;
    case 'com.transistorsoft.dataupdate':
      print("Calling data update");
      await syncDataFromDevice();
      print("Received custom update task");
      break;
    default:
      print("Task $taskId");
      print("Default fetch task");
  }

  // This is the fetch-event callback.
  print('[BackgroundFetch] Event received $taskId');

  // IMPORTANT:  You must signal completion of your task or the OS can punish your app
  // for taking too long in the background.
  //BackgroundFetch.finish(taskId);
}

void _scheduleTask() {
  // Step 2:  Schedule a custom "oneshot" task "com.transistorsoft.datasync" to execute 5000ms from now.
//  BackgroundFetch.scheduleTask(
//    TaskConfig(
//        taskId: 'com.transistorsoft.datasync',
//        delay: 5000, // <-- milliseconds
//        periodic: true,
//        startOnBoot: true,
//        stopOnTerminate: false,
//        enableHeadless: true,
//        requiresDeviceIdle: false,
//        forceAlarmManager: true),
//  );
//
//  BackgroundFetch.scheduleTask(
//    TaskConfig(
//      taskId: 'com.transistorsoft.dataupdate',
//      delay: 10000, // <-- milliseconds
//      periodic: true,
//      startOnBoot: true,
//      stopOnTerminate: false,
//      enableHeadless: true,
//      requiresDeviceIdle: false,
//      forceAlarmManager: true,
//    ),
//  );
}

// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initPlatformState(mounted) async {
  // Configure BackgroundFetch.
//  BackgroundFetch.configure(
//      BackgroundFetchConfig(
//        startOnBoot: true,
//        minimumFetchInterval: 5,
//        stopOnTerminate: false,
//        enableHeadless: true,
//        requiresBatteryNotLow: false,
//        requiresCharging: false,
//        requiresStorageNotLow: false,
//        forceAlarmManager:
//            true, // We are forcing alarm manager to make sure the task is prioritized in android
//        requiresDeviceIdle: false,
//        requiredNetworkType: NetworkType.NONE,
//      ), backgroundFetchHeadlessTask).then((int status) {
//    print('[BackgroundFetch] configure success: $status');
//  }).catchError((e) {
//    print('[BackgroundFetch] configure ERROR: $e');
//  });
//
//  // Optionally query the current BackgroundFetch status.
//  var status = await BackgroundFetch.status;

  //Schedule the tasks
  _scheduleTask();
  _onClickEnable(true);

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  if (!mounted) return;
}

/// Load the data from the device
Future loadDataFromDevice() async {
  final result =
      await BackgroundFetchData.platform.invokeMethod('loadData') as String;

  print('Got load Data ' + result);
}

void _onClickEnable(bool enabled) {
//  if (enabled) {
//    BackgroundFetch.start().then((int status) {
//      print('[BackgroundFetch] start success: $status');
//    }).catchError((e) {
//      print('[BackgroundFetch] start FAILURE: $e');
//    });
//  } else {
//    BackgroundFetch.stop().then((int status) {
//      print('[BackgroundFetch] stop success: $status');
//    });
//  }
}

void _onClickStatus() async {
//  var status = await BackgroundFetch.status;
//  print('[BackgroundFetch] status: $status');
}

/**
   * Sync the data from the device
   */
Future<void> syncDataFromDevice() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    //Send the connection info we got from connect device
    final connectionInfo = prefs.getString('watchInfo');
    if (connectionInfo != null) {
      print('Sending connection info ${connectionInfo}');

      final result = await BackgroundFetchData.platform.invokeMethod(
        'syncData',
        //'connectDevice',
        <String, dynamic>{'connectionInfo': connectionInfo},
      ) as String;

      print('Got Sync Data ' + result);
    }
  } catch (ex) {
    print(ex);
  }
}

Future<void> readDataFromDevice(String deviceInfo) async{
  try {
    print('Sending connection info ${deviceInfo}');

    final result = await BackgroundFetchData.platform.invokeMethod(
      'syncData',
      //'connectDevice',
      <String, dynamic>{'connectionInfo': deviceInfo},
    ) as String;

    print('Got Sync Data ' + result);

  } catch (ex) {
    print(ex);
  }
}
