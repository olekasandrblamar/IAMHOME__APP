import 'package:ceras/config/env.dart';
import 'package:ceras/screens/auth/login_screen.dart';
import 'package:ceras/screens/auth/passwordexpired_screen.dart';
import 'package:ceras/screens/data_screen.dart';
import 'package:ceras/screens/setup/connection_notfound_screen.dart';
import 'package:ceras/screens/setup/setup_connected_screen.dart';
import 'package:ceras/screens/setup/setup_devices_screen.dart';
import 'package:ceras/screens/setup/unabletoconnect_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:ceras/screens/access/camera_screen.dart';
import 'package:ceras/screens/access/locations_screen.dart';
import 'package:ceras/screens/access/notifications_screen.dart';
import 'package:ceras/screens/help/help_widget.dart';
import 'package:ceras/screens/intro_screen.dart';
import 'package:ceras/screens/privacy_screen.dart';
import 'package:ceras/screens/setup/bluetooth_notfound_screen.dart';
import 'package:ceras/screens/setup/setup_active_screen.dart';
import 'package:ceras/screens/setup/setup_connect_screen.dart';
import 'package:ceras/screens/setup/setup_search_screen.dart';
import 'package:ceras/screens/selectlanguage_screen.dart';
import 'package:ceras/screens/settings/settings_screen.dart';

import 'constants/route_paths.dart';
import 'screens/setup/setup_home_screen.dart';

Route<dynamic> generateRoute(
  RouteSettings settings,
  FirebaseAnalytics analytics,
) {
  if (env.flavor == BuildFlavor.production) {
    analytics.setCurrentScreen(screenName: settings.name);
  }

  switch (settings.name) {
    // case RootRoute:
    //   return MaterialPageRoute(builder: (context) => LoginScreen());
    case LoginRoute:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case PasswordExpiredRoute:
      var arguments = settings.arguments as Map<dynamic, dynamic>;
      return MaterialPageRoute(
        builder: (context) => PasswordExpiredScreen(
          routeArgs: arguments,
        ),
      );
    case SelectLanguageRoute:
      return MaterialPageRoute(builder: (context) => SelectLanguageScreen());
    case NotificationsRoute:
      return MaterialPageRoute(builder: (context) => NotificationsScreen());
    case LocationsRoute:
      return MaterialPageRoute(builder: (context) => LocationsScreen());
    case CameraRoute:
      return MaterialPageRoute(builder: (context) => CameraScreen());
    case IntroRoute:
      return MaterialPageRoute(builder: (context) => IntroScreen());
    case PrivacyRoute:
      return MaterialPageRoute(builder: (context) => PrivacyScreen());
    case SetupDevicesRoute:
      return MaterialPageRoute(builder: (context) => SetupDevicesScreen());
    case SetupHomeRoute:
      return MaterialPageRoute(builder: (context) => SetupHomeScreen());
    case SetupSearchRoute:
      return MaterialPageRoute(builder: (context) => SetupSearchScreen());
    case SetupActiveRoute:
      var arguments = settings.arguments as Map<dynamic, dynamic>;
      return MaterialPageRoute(
        builder: (context) => SetupActiveScreen(
          routeArgs: arguments,
        ),
      );
    case SetupConnectRoute:
      var arguments = settings.arguments as Map<dynamic, dynamic>;
      return MaterialPageRoute(
        builder: (context) => SetupConnectScreen(
          routeArgs: arguments,
        ),
      );
    case SetupConnectedRoute:
      var arguments = settings.arguments as Map<dynamic, dynamic>;
      return MaterialPageRoute(
        builder: (context) => SetupConnectedScreen(
          routeArgs: arguments,
        ),
      );
    case BluetoothNotfoundRoute:
      return MaterialPageRoute(builder: (context) => BluetoothNotfoundScreen());
    case ConnectionNotfoundRoute:
      return MaterialPageRoute(
          builder: (context) => ConnectionNotfoundScreen());
    case UnabletoconnectRoute:
      return MaterialPageRoute(builder: (context) => UnabletoconnectScreen());
    case HelpRoute:
      return MaterialPageRoute(builder: (context) => HelpScreen());
    case SettingsRoute:
      return MaterialPageRoute(builder: (context) => SettingsScreen());
    case DataRoute:
      return MaterialPageRoute(builder: (context) => DataScreen());
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('No path for ${settings.name}'),
          ),
        ),
      );
  }
}
