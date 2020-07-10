import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifeplus/config/http.dart';
import 'package:lifeplus/config/navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final http = HttpClient().http;

  String _watchId;

  bool get isAuth {
    return _watchId != null;
  }

  String get watchId {
    return _watchId;
  }

  Future<bool> saveWatchId(watchInfo) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('watchId', watchInfo);

    _watchId = watchInfo;

    notifyListeners();
    return true;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('watchId')) {
      return false;
    }

    final String checkWatchId = prefs.getString('watchId');

    if (checkWatchId.isEmpty) {
      logout();
      return false;
    }

    _watchId = checkWatchId;

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _watchId = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('watchId');
    NavigationService.goBackHome();
    // prefs.clear();
  }
}
