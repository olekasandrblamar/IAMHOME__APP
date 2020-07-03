import 'package:flutter/material.dart';

// import 'package:lifeplus/screens/auth/switchstore_screen.dart';
// import 'package:lifeplus/screens/auth/login_screen.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  static navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState.pushNamed(routeName, arguments: arguments);
  }

  static goBack() {
    return navigatorKey.currentState.pop();
  }

  static goBackHome() {
    // return navigatorKey.currentState.pushAndRemoveUntil(
    //     MaterialPageRoute(
    //       builder: (BuildContext context) => LoginScreen(),
    //       settings: const RouteSettings(name: routes.LoginRoute),
    //     ),
    //     (Route<dynamic> route) => false);
  }

  static goToSwitchStore() {
    // return navigatorKey.currentState.pushAndRemoveUntil(
    //     MaterialPageRoute(
    //       builder: (BuildContext context) => SwitchStoreScreen(),
    //       settings: const RouteSettings(name: routes.SwitchStoreRoute),
    //     ),
    //     (Route<dynamic> route) => false);
  }
}

//Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
