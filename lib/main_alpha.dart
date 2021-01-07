import 'dart:async';
import 'dart:io';

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

    BuildEnvironment.init(
      flavor: BuildFlavor.alpha,
      baseUrl: 'https://device.alpha.myceras.com/api/v1/device',
      baseUrl2: 'https://api',
      authUrl: 'https://auth.alpha.myceras.com',
      accessKey: 'nya8zsihq17z1w6x',
      secret: 'k72eiwnca95u33er0ujb',
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
      //await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    });
  } catch (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
    print(error);
  }
}
