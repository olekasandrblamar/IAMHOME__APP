import 'dart:async';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
//import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ceras/config/background_fetch.dart';

import 'app.dart';
import 'config/env.dart';

void main() {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
    };

    BuildEnvironment.init(
      flavor: BuildFlavor.production,
      baseUrl: 'https://devicemgmt.myceras.com/api/v1/device/',
      baseUrl2: 'https://api',
    );

    assert(env != null);

    SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    runZoned<Future<void>>(() async {
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
