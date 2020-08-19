import 'dart:async';
import 'dart:convert';

import 'package:ceras/models/devices_model.dart';
import 'package:flutter/material.dart';
import 'package:ceras/config/http.dart';
import 'package:ceras/config/navigation_service.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final http = HttpClient().http;

  WatchModel _watchInfo;
  String _deviceType;
  DevicesModel _deviceData;

  bool get isAuth {
    return _watchInfo != null;
  }

  WatchModel get watchInfo {
    return _watchInfo;
  }

  Future<String> get deviceType async {
    final prefs = await SharedPreferences.getInstance();
    _deviceType = prefs.getString('deviceType');

    return _deviceType;
  }

  void setDeviceType(String deviceType) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceType', deviceType);

    _deviceType = deviceType;
  }

  void setDeviceData(DevicesModel deviceData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('deviceData', json.encode(deviceData));

    _deviceData = deviceData;
  }

  Future<DevicesModel> get deviceData async {
    final prefs = await SharedPreferences.getInstance();
    final checkDeviceInfo = DevicesModel.fromJson(
        json.decode(prefs.getString('deviceData')) as Map<String, dynamic>);

    _deviceData = checkDeviceInfo;

    return checkDeviceInfo;
  }

  Future<WatchModel> get watchData async {
    final prefs = await SharedPreferences.getInstance();
    final checkWatchInfo = WatchModel.fromJson(
        json.decode(prefs.getString('watchInfo')) as Map<String, dynamic>);

    _watchInfo = checkWatchInfo;

    return checkWatchInfo;
  }

  Future<bool> saveWatchInfo(WatchModel watchInfo) async {
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

    final WatchModel checkwatchInfo = WatchModel.fromJson(
        json.decode(prefs.getString('watchInfo')) as Map<String, dynamic>);

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
