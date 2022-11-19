import 'dart:io';
import 'dart:convert';
import 'package:ceras/config/env.dart';
import 'package:ceras/config/user_deviceinfo.dart';
import 'package:ceras/services/foreground_service.dart';
import 'package:ceras/providers/applanguage_provider.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/screens/intro_screen.dart';
// import 'package:ceras/screens/setup/setup_active_screen.dart';
import 'package:ceras/screens/splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_localizations.dart';
import 'config/background_fetch.dart';
import 'config/dynamiclinks_setup.dart';
import 'config/navigation_service.dart';
// import 'config/push_notifications.dart';
import 'constants/route_paths.dart' as routes;
import 'data/language_data.dart';
import 'router.dart' as router;
import 'screens/setup/setup_home_screen.dart';
import 'theme.dart';
import 'package:terra_flutter_bridge/terra_flutter_bridge.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
// import 'config/locator.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLanguageProvider appLanguage = AppLanguageProvider();
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  MyForegroundService fService;
  //////////////For Terra API///////////////////
  bool _initialised = false;
  bool _connected = false;
  bool _daily = false;
  String _testText = "Hello World";
  ////////////////////////////////////////////////
  @override
  void initState() {
    super.initState();
    /////////////////FLUTTER LEVEL FOREGROUND SERVICE START/////////////////////////////////
    ///
    // fService = new MyForegroundService();
    // fService.isForegroundRunning().then((reqResult) {
    //   if (!reqResult) {
    //     fService.initForegroundService();
    //     fService.startForegroundTask();
    //   }
    // });
    //////////////////////////////////////////////////////////////////////

    /////////////////FOREGROUND SERVICE STOP/////////////////////////////////////////////////////
    // fService.stopForegroundTask();
    //////////////////////////////////////////////////////////////////////
    _handleStartUpLogic();

    appLanguage.fetchLocale();

    ///////////For Terra API////////////////////////////////
//    initTerraFunctionState();


    ///////////////////////////////////////////////////
  }
  ///////////////For Terra API /////////////////////
  Future<void> initTerraFunctionState() async {
    bool initialised = false;
    bool connected = false;
    bool daily = false;
    String testText;
    Connection c = Connection.samsung;
    /*
    To use the Samsung integration, the user needs Health Platform downloaded on their device and their Samsung Health Account linked to Health Platform. This can be done by going on Samsung Health -> Profile -> Settings -> Connected Services -> Health Platform and giving Health Platform access to their data.
    */

    // Function messages may fail, so we use a try/catch Exception.
    // We also handle the message potentially returning null.
    // USE YOUR OWN CATCH BLOCKS
    // HAVING ALL FUNCTIONS IN THE SAME CATCH IS NOT A GOOD IDEA
    try {
      DateTime now = DateTime.now().toUtc();
      DateTime lastMidnight = DateTime(now.year, now.month, now.day);
      Fluttertoast.showToast(
        msg: "trying integration init",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      initialised =
          await TerraFlutter.initTerra("ceras-dev-y5kN5MDRKv", "67d93d7e-09f1-4402-b5ad-fb437f3b4628") ??
              false;
      String str;
      if(_initialised) str = "true";
      else str = "false";
      Fluttertoast.showToast(
        msg: "Did integration init:" + str,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );


      connected = await TerraFlutter.initConnection(c, "a3e614f4481dbb92cca6d2957bde3f71951551e726710c2f7b88d7c7c5174562", false, []) ??
          false;

      if(_connected) str = "true";
      else str = "false";
      Fluttertoast.showToast(
        msg: "Is integration connected:" + str,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      testText = await TerraFlutter.getUserId(c) ?? "1234";

      Fluttertoast.showToast(
        msg: "User id:" + testText,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      daily = await TerraFlutter.getDaily(
          c, lastMidnight, now) ??
          false;
      daily = await TerraFlutter.getAthlete(c) ?? false;
      daily = await TerraFlutter.getMenstruation(
          c, DateTime(2022, 9, 25), DateTime(2022, 9, 30)) ??
          false;
      daily = await TerraFlutter.getNutrition(
          c, DateTime(2022, 7, 25), DateTime(2022, 7, 26)) ??
          false;
      daily = await TerraFlutter.getSleep(
          c, now.subtract(Duration(days: 1)), now) ??
          false;
      daily = await TerraFlutter.getActivity(
          c, DateTime(2022, 7, 25), DateTime(2022, 7, 26)) ??
          false;

      if(_daily) str = "true";
      else str = "false";
      Fluttertoast.showToast(
        msg: "Requested daily webhook for integration:" + str,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } on Exception catch (e) {
      // print('error caught: $e');
      testText = "Some exception went wrong";
      initialised = false;
      connected = false;
      daily = false;
      Fluttertoast.showToast(
        msg: testText,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );

    }
    Fluttertoast.showToast(
      msg: "No exception occured",
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _initialised = initialised;
      _connected = connected;
      _daily = daily;
      _testText = testText;
    });


  }
  /////////////////////////////////////////////////////////
  Future<void> _handleStartUpLogic() async {
    await _initializeFlutterFire();

    final prefs = await SharedPreferences.getInstance();
    final redeemCode = prefs.getString('redeemCode');

    if (redeemCode != null) {
      // final authUrl = await prefs.getString('authUrl');
      // final baseUrl = await prefs.getString('baseUrl');
      //
      // await prefs.setString('authUrl', authUrl);
      // await prefs.setString('apiBaseUrl', baseUrl);
    } else {
      await prefs.setString('apiBaseUrl', env.baseUrl);
      await prefs.setString('serverBaseUrl', env.serverUrl);
    }

    await DevicesProvider.migrateDeviceModel();

    await updateDeviceInfo();

    // await PushNotificationsManager(context).init();
    await setupInteractedMessage();

    DynamicLinksSetup().initDynamicLinks();
    // initalizeBackgroundFetch();

    // await initPlatformState(false);
  }

  Future<void> setupInteractedMessage() async {
    var _firebaseMessaging = FirebaseMessaging.instance;
    var token = await _firebaseMessaging.getToken();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationToken', token);

    //This is used when the notification is opened when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    //This is called when the app is open and the message is received
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //_handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) async {
    if (message.data['action'] == 'device_sync') {
      var payload =
      json.decode(message.data['payload']) as Map<String, dynamic>;
      var deviceId = payload['deviceId'].toString();
      var devices = await DevicesProvider.loadDevices();
      var deviceIndex = devices.indexWhere(
            (element) => (element.watchInfo.deviceId == deviceId),
      );

      if (deviceIndex >= 0) {
        NavigationService.navigateTo(routes.SetupActiveRoute,
            arguments: {'deviceIndex': deviceIndex});
      }
    }
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    await Firebase.initializeApp();

    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      // Handle Crashlytics enabled status when not in Debug,
      // e.g. allow your users to opt-in to crash reporting.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness:
        Platform.isAndroid ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.grey,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: appLanguage,
        ),
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProvider.value(
          value: DevicesProvider(),
        ),
      ],
      child: Consumer2<AuthProvider, AppLanguageProvider>(
        builder: (ctx, auth, appLanguage, _) {
          return MaterialApp(
            title: 'CERAS',
            debugShowCheckedModeBanner: false,
            // theme: ThemeData(
            //   primarySwatch: Colors.blue,
            //   textTheme: AppTheme.textTheme,
            //   // pageTransitionsTheme: PageTransitionsTheme(
            //   //   builders: {
            //   //     TargetPlatform.android: CustomPageTransitionBuilder(),
            //   //     TargetPlatform.iOS: CustomPageTransitionBuilder(),
            //   //   },
            //   // ),
            // ),
            // darkTheme: ThemeData.dark(),
            // theme: myTheme,
            theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            initialRoute: routes.RootRoute,
            home: _buildHomeWidget(auth),
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: (settings) => router.generateRoute(
              settings,
              analytics,
            ),
            locale: appLanguage.appLocal,
            supportedLocales: [...SupportedLocals],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }

  Widget _buildHomeWidget(AuthProvider auth) {
    if (auth.isAuth) {
      return SetupHomeScreen();
    } else {
      return FutureBuilder(
        future: Future.wait([
          auth.checkWalthrough(),
        ]),
        builder: (ctx, authResultSnapshot) {
          if (authResultSnapshot.connectionState == ConnectionState.done) {
            if (authResultSnapshot.data[0]) {
              return IntroScreen();
            } else {
              return SetupHomeScreen();
            }
          } else {
            return SplashScreen();
          }
        },
      );
    }
  }
}
