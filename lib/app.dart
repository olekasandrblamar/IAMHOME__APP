import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ceras/config/background_fetch.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/screens/intro_screen.dart';
import 'package:ceras/screens/setup/setup_active_screen.dart';
import 'package:ceras/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:ceras/providers/applanguage_provider.dart';

import 'config/app_localizations.dart';
import 'config/navigation_service.dart';
import 'constants/route_paths.dart' as routes;
import 'router.dart' as router;
import 'theme.dart';
// import 'config/locator.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLanguageProvider appLanguage = AppLanguageProvider();

  @override
  void initState() {
    // NotificationOneSignal().initialiseOneSignal();
    // DynamicLinksSetup().initDynamicLinks();
    // initalizeBackgroundFetch();

    appLanguage.fetchLocale();

    // TODO: implement initState
    super.initState();
  }

  initalizeBackgroundFetch() async {
    await initPlatformState(false);
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
      ],
      child: Consumer2<AuthProvider, AppLanguageProvider>(
        builder: (ctx, auth, appLanguage, _) {
          return MaterialApp(
            title: 'lifeplus',
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
            theme: myTheme,
            initialRoute: routes.RootRoute,
            home: _buildHomeWidget(auth),
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: (settings) => router.generateRoute(
              settings,
            ),
            locale: appLanguage.appLocal,
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('hi', 'IN'),
              const Locale('ar', 'AE'),
              const Locale('zh', 'CN'),
              const Locale('nl', 'NL'),
              const Locale('fr', 'FR'),
              const Locale('de', 'DE'),
              const Locale('el', 'GR'),
              const Locale('hi', 'IN'),
              const Locale('it', 'IT'),
              const Locale('ja', 'JP'),
              const Locale('ko', 'KR'),
              const Locale('ms', 'MY'),
              const Locale('pt', 'PT'),
              const Locale('ru', 'RU'),
              const Locale('es', 'ES'),
              const Locale('sv', 'SE'),
              const Locale('tr', 'TR'),
              const Locale('th', 'TH'),
              const Locale('vi', 'VN'),
            ],
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
      return SetupActiveScreen();
    } else {
      return FutureBuilder(
        future: auth.tryAutoLogin(),
        builder: (ctx, authResultSnapshot) =>
            authResultSnapshot.connectionState == ConnectionState.waiting
                ? SplashScreen()
                : IntroScreen(),
      );
    }
  }
}
