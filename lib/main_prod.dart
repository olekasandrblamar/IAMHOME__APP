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

    BuildEnvironment.init(
      environment: 'Ceras',
      flavor: BuildFlavor.production,
      environmentUrl: 'https://tracker.ceras.io/api/v1/device',
      baseUrl: 'https://tracker.ceras.io/api/v1/device/',
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
