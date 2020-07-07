import 'package:flutter/material.dart';
import 'package:lifeplus/screens/access/camera_screen.dart';
import 'package:lifeplus/screens/access/locations_screen.dart';
import 'package:lifeplus/screens/access/notifications_screen.dart';
import 'package:lifeplus/screens/connect_device_screen.dart';
import 'package:lifeplus/screens/connect_doctor_screen.dart';
import 'package:lifeplus/screens/intro_screen.dart';
import 'package:lifeplus/screens/setup_device_screen.dart';
import 'package:lifeplus/screens/start_screen.dart';

import 'constants/route_paths.dart';
import 'screens/home_screen.dart';

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
    case StartRoute:
      return MaterialPageRoute(builder: (context) => StartScreen());
    case HomeRoute:
      return MaterialPageRoute(builder: (context) => HomeScreen());
    case ConnectDeviceRoute:
      return MaterialPageRoute(builder: (context) => ConnectDeviceScreen());
    case SetupDeviceRoute:
      return MaterialPageRoute(builder: (context) => SetupDeviceScreen());
    case ConnectDoctorRoute:
      return MaterialPageRoute(builder: (context) => ConnectDoctorScreen());
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
