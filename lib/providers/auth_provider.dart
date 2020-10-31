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

  bool _walthrough = true;

  String _authToken;
  String _refreshToken;
  DateTime _userExpiryDate;
  String _userId;

  String get token {
    if (_userExpiryDate != null &&
        _userExpiryDate.isAfter(DateTime.now()) &&
        _refreshToken != null) {
      return _refreshToken;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  bool get isAuth {
    return _userId != null;
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
      http.options.headers.addAll({"ACCESSKEY": env.accessKey, "SECRET": env.secret});
      final response = await http.post(
        env.authUrl + 'oauth/authorize',
        data: {"userName": email, "password": password, "orgId": "PATIENT"}
      );

      final responseData = response.data;

      print(responseData);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      if (responseData['access_token'] == null) {
        throw HttpException('You dont have access to patient');
      }

      _authToken = responseData['access_token'];
      _refreshToken = responseData['refresh_token'];

      var jwtData = parseJwt(_refreshToken);
      _userExpiryDate = DateTime.now().add(
        Duration(
          seconds: jwtData['exp'],
        ),
      );
      _userId = jwtData['sub'];

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

    print(extractedUserData);

    _authToken = extractedUserData['authToken'];
    _refreshToken = extractedUserData['refreshToken'];
    _userId = extractedUserData['userId'];
    _userExpiryDate = expiryDate;
    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    _authToken = null;
    _refreshToken = null;
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
