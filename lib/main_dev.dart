import 'dart:async';
import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'config/env.dart';

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  BackgroundFetch.finish(taskId);
}

void main() {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    BuildEnvironment.init(
      flavor: BuildFlavor.development,
      baseUrl: 'https:///api',
      baseUrl2: 'https:///api',
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
      BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    });
  } catch (error, stackTrace) {
    print(error);
  }
}
