import 'dart:async';
import 'dart:io';

//import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'dart:convert';
import 'constants/route_paths.dart' as routes;
import 'config/navigation_service.dart';
import 'package:flutter/services.dart';
//import 'package:ceras/config/background_fetch.dart';

import 'app.dart';
import 'config/env.dart';

Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  if (message.data['action'] == 'device_sync') {
    var payload = json.decode(message.data['payload']) as Map<String,dynamic>;
    var deviceId = payload['deviceId'].toString();
    var devices = await DevicesProvider.loadDevices();
    var deviceIndex = devices.indexWhere(
          (element) => (element.watchInfo.deviceId == deviceId),
    );

    if (deviceIndex >=0 ) {
      NavigationService.navigateTo(routes.SetupActiveRoute,arguments: {'deviceIndex': deviceIndex});
    }
  }
}

void main() {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    BuildEnvironment.init(
      environment: 'Ceras Alpha',
      flavor: BuildFlavor.alpha,
      environmentUrl: 'https://device.alpha.myceras.com/api/v1/device',
      baseUrl: 'https://device.alpha.myceras.com/api/v1/device/',
      baseUrl2: 'https://api',
      authUrl: 'https://auth.ceras.io',
      accessKey: 'QU5CZRR7XXBR',
      secret: 'NUSR82XMJ9GGH57YK03V',
    );

    assert(env != null);

    SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    runZoned<Future<void>>(() async {
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      HttpClient.enableTimelineLogging = true;
      runApp(MyApp());

      // Register to receive BackgroundFetch events after app is terminated.
      // Requires {stopOnTerminate: false, enableHeadless: true}
      //await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    });
  } catch (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
    print(error);
  }
}
