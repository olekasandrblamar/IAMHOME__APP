import 'dart:async';
import 'dart:convert';

import 'package:ceras/config/user_deviceinfo.dart';
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
  bool _walthrough = true;

  bool get isAuth {
    return _watchInfo != null;
  }

  bool get isWalthrough {
    return _walthrough;
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

  Future<WatchModel> get watchData async {
    final prefs = await SharedPreferences.getInstance();
    final WatchModel checkWatchInfo = WatchModel.fromJson(
        json.decode(prefs.getString('watchInfo')) as Map<String, dynamic>);

    return checkWatchInfo;
  }

  Future<bool> saveWatchInfo(WatchModel watchInfo) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('watchInfo', json.encode(watchInfo));

    _watchInfo = watchInfo;

    notifyListeners();
    return true;
  }

  Future<WatchModel> _checkWatchInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final WatchModel checkwatchInfo = WatchModel.fromJson(
        json.decode(prefs.getString('watchInfo')) as Map<String, dynamic>);

    _watchInfo = checkwatchInfo;

    return _watchInfo;
  }

  Future<dynamic> _checkUserDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final userDeviceInfo = await getUserDeviceInfo();
    final _userDeviceInfo =
        prefs.setString('userDeviceInfo', json.encode(userDeviceInfo));

    return _userDeviceInfo;
  }

  Future<bool> checkWalthrough() async {
    final prefs = await SharedPreferences.getInstance();

    final walthrough = prefs.getBool('walthrough');
    _walthrough = walthrough ?? true;

    // notifyListeners();

    return _walthrough;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    await _checkUserDeviceInfo();
    // await _checkWalthrough();

    if (!prefs.containsKey('watchInfo')) {
      return false;
    }

    final checkwatchInfo = await _checkWatchInfo();
    if (checkwatchInfo == null) {
      // await logout();
      return false;
    }

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _watchInfo = null;
    _deviceData = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('watchInfo');
    prefs.remove('deviceData');
    NavigationService.goBackHome();
    // prefs.clear();
  }
}
