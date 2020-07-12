import 'package:flutter/material.dart';
import 'package:lifeplus/screens/access/camera_screen.dart';
import 'package:lifeplus/screens/access/locations_screen.dart';
import 'package:lifeplus/screens/access/notifications_screen.dart';
import 'package:lifeplus/screens/intro_screen.dart';
import 'package:lifeplus/screens/privacy_screen.dart';
import 'package:lifeplus/screens/setup/bluetooth_notfound_screen.dart';
import 'package:lifeplus/screens/setup/setup_active_screen.dart';
import 'package:lifeplus/screens/setup/setup_connect_screen.dart';
import 'package:lifeplus/screens/setup/setup_search_screen.dart';

import 'constants/route_paths.dart';
import 'screens/setup/setup_home_screen.dart';

Route<dynamic> generateRoute(
  RouteSettings settings,
) {
  switch (settings.name) {
    // case RootRoute:
    //   return MaterialPageRoute(builder: (context) => LoginScreen());
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
    case SetupHomeRoute:
      return MaterialPageRoute(builder: (context) => SetupHomeScreen());
    case SetupSearchRoute:
      return MaterialPageRoute(builder: (context) => SetupSearchScreen());
    case SetupActiveRoute:
      return MaterialPageRoute(builder: (context) => SetupActiveScreen());
    case SetupConnectRoute:
      var arguments = settings.arguments as Map<dynamic, dynamic>;
      return MaterialPageRoute(
          builder: (context) => SetupConnectScreen(
                routeArgs: arguments,
              ));
    case BluetoothNotfoundRoute:
      return MaterialPageRoute(builder: (context) => BluetoothNotfoundScreen());
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
