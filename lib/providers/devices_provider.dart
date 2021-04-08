import 'dart:io';
import 'dart:convert';

import 'package:ceras/config/env.dart';
import 'package:ceras/models/currentversion_model.dart';
import 'package:ceras/models/promo_model.dart';
import 'package:ceras/models/profile_model.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/trackers/tracker_data_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ceras/config/http.dart';
import 'package:ceras/config/navigation_service.dart';

class DevicesProvider extends ChangeNotifier {
  final http = HttpClient().http;

  final mobileDataHttp = HttpClient().mobileDataHttp;

  List<DevicesModel> _deviceData = [];
  WatchModel _watchInfo;

  Future<String> get _baseUrl async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = await prefs.getString('apiBaseUrl');

    if (baseUrl != null) {
      return baseUrl;
    } else {
      return env.baseUrl;
    }
  }

  Future<void> fetchAllDevices() async {
    try {
      final baseUrl = await _baseUrl;
      print(baseUrl);
      final response = await http.get(
        baseUrl + '/master/masterDevices',
      );

      final responseData = response.data;
      final formattedData = <DevicesModel>[];

      responseData.forEach(
        (data) {
          if (_deviceData != null && !_deviceData.isEmpty) {
            bool check = _deviceData.any(
              (element) => (element.deviceMaster['displayName'] !=
                  data['deviceMaster']['displayName']),
            );

            if (check) {
              formattedData.add(
                DevicesModel.fromJson(data),
              );
            }
          } else {
            formattedData.add(
              DevicesModel.fromJson(data),
            );
          }
        },
      );

      return formattedData;
    } catch (error) {
      throw error;
    }
  }

  Future<List<DevicesModel>> getDevicesData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var prefData = prefs.getString('deviceData');

    // prefs.clear();

    if (prefData == null) {
      return [];
    }

    // print("Got prefs data ${prefData}");

    //Check if it is an object or array. If it is an object we need to convert to array
    if (prefData.startsWith("{")) {
      var oldDeviceData = json.decode(prefData);
      final migrateData = [oldDeviceData];
      var encoded = json.encode(migrateData);
      prefs.setString('deviceData', encoded);
      prefData = encoded;
    }

    // print("Got prefs data ${prefData}");

    final List<DevicesModel> formattedData = [];
    final List existingDeviceData = json.decode(prefData);

    // print(existingDeviceData);

    existingDeviceData.forEach(
      (data) {
        formattedData.add(
          DevicesModel.fromJson(data),
        );
      },
    );

    _deviceData = formattedData;
    notifyListeners();

    return formattedData;
  }

  Future<DevicesModel> getDeviceData(int index) async {
    DevicesModel deviceData = _deviceData[index];
    return deviceData;
  }

  void setDeviceData(DevicesModel deviceData) async {
    final prefs = await SharedPreferences.getInstance();
    final prefData = prefs.getString('deviceData');

    final List<DevicesModel> formattedData = [];

    if (prefData != null) {
      final List existingDeviceData = json.decode(prefData);

      existingDeviceData.forEach(
        (data) {
          formattedData.add(
            DevicesModel.fromJson(data),
          );
        },
      );
    }

    final data = [...formattedData, deviceData];
    prefs.setString('deviceData', json.encode(data));

    _deviceData = data;
  }

  Future<String> _getMacId() async {
    final prefs = await SharedPreferences.getInstance();
    var macAddress = '';
    await prefs.reload();

    if (Platform.isIOS) {
      macAddress = prefs.getString('device_macid');
    } else {
      var watchInfo =
          json.decode(prefs.getString('watchInfo')) as Map<String, dynamic>;
      macAddress = WatchModel.fromJson(watchInfo).deviceId;
    }

    return macAddress.replaceAll(":", "");
  }

  Future<Map<String, dynamic>> _getDeviceRequest() async {
    return {"devices": await _getMacId()};
  }

  Future<Temperature> getLatestTemperature() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/lastValue/temperature',
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        print("Got temp ${response.data}");
        return Temperature.fromJson(response.data);
      }
    } catch (error) {
      print("Error on temp" + error.toString());
      return null;
    }
  }

  Future<HeartRate> getLatestHeartRate() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/lastValue/heartrate',
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        return HeartRate.fromJson(response.data);
      }
    } catch (error) {
      print("Error on temp" + error.toString());
      return null;
    }
  }

  Future<OxygenLevel> getLatestOxygenLevel() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/lastValue/bloodOxygen',
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        return OxygenLevel.fromJson(response.data);
      }
    } catch (error) {
      print("Error on temp" + error.toString());
      return null;
    }
  }

  Future<DailySteps> getLatestSteps() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/lastValue/dailySteps',
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        return DailySteps.fromJson(response.data);
      }
    } catch (error) {
      print("Error on temp" + error.toString());
      return null;
    }
  }

  Future<BloodPressure> getLatestBloodPressure() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/lastValue/bloodPressure',
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        return BloodPressure.fromJson(response.data);
      }
    } catch (error) {
      print("Error on temp" + error.toString());
      return null;
    }
  }

  Future<Calories> getLatestCalories() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/lastValue/calories',
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        return Calories.fromJson(response.data);
      }
    } catch (error) {
      print("Error on temp" + error.toString());
      return null;
    }
  }

  Future<ProfileModel> getProfileInfo() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        env.environmentUrl + '/profileInfo',
        queryParameters: {"deviceId": await _getMacId()},
      );

      if (response.data != null) {
        return ProfileModel.fromJson(response.data);
      }
    } catch (error) {
      print("Error on profile" + error.toString());
      return null;
    }
  }

  Future<bool> saveWatchInfo(WatchModel watchInfo) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('watchInfo', json.encode(watchInfo));

    _watchInfo = watchInfo;

    notifyListeners();
    return true;
  }

  Future<void> removeDevice(int index) async {
    _watchInfo = null;
    _deviceData.removeAt(index);

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('watchInfo');
    prefs.setString('deviceData', json.encode(_deviceData));

    NavigationService.goBackHome();
    // prefs.clear();
  }

  Future<CurrentversionModel> currentVersion() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await http.get(baseUrl + '/currentVersion');

      if (response.data != null) {
        return CurrentversionModel.fromJson(response.data);
      }
    } catch (error) {
      print("Error on currentVersion" + error.toString());
      return null;
    }
  }

  Future<PromoModel> redeemPromo(String code) async {
    try {
      final baseUrl = await _baseUrl;
      final response =
          await http.get(env.environmentUrl + '/environment/' + code);

      if (response.data != null) {
        return PromoModel.fromJson(response.data);
      }
    } catch (error) {
      print("Error on promo" + error.toString());
      return null;
    }
  }
}
