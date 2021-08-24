import 'dart:io';

import 'package:ceras/config/env.dart';
import 'package:ceras/config/user_deviceinfo.dart';
import 'package:ceras/providers/applanguage_provider.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/screens/intro_screen.dart';
import 'package:ceras/screens/splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_localizations.dart';
import 'config/dynamiclinks_setup.dart';
import 'config/navigation_service.dart';
import 'config/push_notifications.dart';
import 'constants/route_paths.dart' as routes;
import 'data/language_data.dart';
import 'router.dart' as router;
import 'screens/setup/setup_home_screen.dart';
import 'theme.dart';
// import 'config/locator.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLanguageProvider appLanguage = AppLanguageProvider();
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    super.initState();

    _handleStartUpLogic();

    appLanguage.fetchLocale();
  }

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
    }

    await updateDeviceInfo();

    // await PushNotificationsManager(context).init();
    await PushNotificationsManager().initNotifications(context);

    DynamicLinksSetup().initDynamicLinks();
    // initalizeBackgroundFetch();

    // await initPlatformState(false);
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
