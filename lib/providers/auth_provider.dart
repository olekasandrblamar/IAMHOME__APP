import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifeplus/config/http.dart';
import 'package:lifeplus/config/navigation_service.dart';
import 'package:lifeplus/models/watchdata_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final http = HttpClient().http;

  WatchData _watchInfo;

  bool get isAuth {
    return _watchInfo != null;
  }

  WatchData get watchInfo {
    return _watchInfo;
  }

  Future<WatchData> get watchData async {
    final prefs = await SharedPreferences.getInstance();
    final WatchData checkWatchInfo = WatchData.fromJson(json.decode(prefs.getString('watchInfo')));

    return checkWatchInfo;
  }

  Future<bool> saveWatchInfo(WatchData watchInfo) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('watchInfo', json.encode(watchInfo));

    _watchInfo = watchInfo;

    notifyListeners();
    return true;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('watchInfo')) {
      return false;
    }


    final WatchData checkwatchInfo = WatchData.fromJson(json.decode(prefs.getString('watchInfo')));

    if (checkwatchInfo == null) {
      logout();
      return false;
    }

    _watchInfo = checkwatchInfo;

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _watchInfo = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('watchInfo');
    NavigationService.goBackHome();
    // prefs.clear();
  }
}
