import 'dart:async';
import 'dart:convert';

import 'package:ceras/config/user_deviceinfo.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:flutter/material.dart';
import 'package:ceras/config/http.dart';
import 'package:ceras/config/navigation_service.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ceras/config/env.dart';

import 'package:dio/dio.dart';

import 'package:ceras/helpers/http_exception.dart';
import 'package:ceras/helpers/parse_jwt.dart';

class AuthProvider with ChangeNotifier {
  final http = HttpClient().http;

  String _authToken;
  String _refreshToken;
  DateTime _userExpiryDate;
  String _userId;

  WatchModel _watchInfo;
  String _deviceType;
  DevicesModel _deviceData;
  bool _walthrough = true;

  String get token {
    if (_userExpiryDate != null &&
        _userExpiryDate.isAfter(DateTime.now()) &&
        _authToken != null) {
      return _authToken;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

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

  Future<bool> validateAndLogin({
    @required String email,
    @required String password,
  }) async {
    try {
      final response = await http.post(
        env.authUrl + 'oauth/authorize',
        data: {"userName": email, "password": password, "orgId": "PATIENT"},
      );

      final responseData = response.data;

      print(responseData);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _authToken = responseData['access_token'];
      _refreshToken = responseData['refresh_token'];

      var jwtData = parseJwt(_authToken);
      _userExpiryDate = DateTime.now().add(
        Duration(
          seconds: jwtData['exp'],
        ),
      );
      _userId = jwtData['uniqueProperty'];

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'refreshToken': _refreshToken,
          'authToken': _authToken,
          'userId': _userId,
          'userExpiryDate': _userExpiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);

      return true;
    } on DioError catch (error) {
      throw HttpException(error?.response?.data['message']);
    } catch (error) {
      throw error;
    }
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

  Future<bool> tryAuthLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['userExpiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _authToken = extractedUserData['authToken'];
    _userId = extractedUserData['userId'];
    _userExpiryDate = expiryDate;
    notifyListeners();

    return true;
  }

  Future<void> removeDevice() async {
    _watchInfo = null;
    _deviceData = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('watchInfo');
    prefs.remove('deviceData');
    NavigationService.goBackHome();
    // prefs.clear();
  }

  Future<void> logout() async {
    _authToken = null;
    _userId = null;
    _userExpiryDate = null;

    // if (_authTimer != null) {
    //   _authTimer.cancel();
    //   _authTimer = null;
    // }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    NavigationService.goBackHome();
    // prefs.clear();
  }
}
