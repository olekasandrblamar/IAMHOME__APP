import 'dart:async';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ceras/config/background_fetch.dart';

import 'app.dart';
import 'config/env.dart';

void main() {
  try {
    // Set `enableInDevMode` to true to see reports while in debug mode
    // This is only to be used for confirming that reports are being
    // submitted as expected. It is not intended to be used for everyday
    // development.
    // Crashlytics.instance.enableInDevMode = false;

    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = Crashlytics.instance.recordFlutterError;

    WidgetsFlutterBinding.ensureInitialized();

    BuildEnvironment.init(
      flavor: BuildFlavor.alpha,
      baseUrl: 'https://devicemgmt.alpha.myceras.com/api/v1/device/',
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
      HttpClient.enableTimelineLogging = true;
      runApp(MyApp());

      // Register to receive BackgroundFetch events after app is terminated.
      // Requires {stopOnTerminate: false, enableHeadless: true}
      await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    });
  } catch (error, stackTrace) {
    Crashlytics.instance.recordError(error, stackTrace);
    print(error);
  }
}
