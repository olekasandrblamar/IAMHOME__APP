import 'dart:io';
import 'dart:convert';

import 'package:ceras/config/env.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/trackers/tracker_data_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ceras/config/http.dart';

class DevicesProvider extends ChangeNotifier {
  final http = HttpClient().http;

  Future<void> fetchAllDevices() async {
    try {
      final response = await http.get(
        env.baseUrl + 'master/masterDevices',
      );

      final responseData = response.data;
      final formattedData = <DevicesModel>[];

      responseData.forEach(
        (data) {
          formattedData.add(
            DevicesModel.fromJson(data),
          );
        },
      );

      return formattedData;
    } catch (error) {
      throw error;
    }
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
      final response = await http.get(env.baseUrl + 'lastValue/temperature',
          queryParameters: await _getDeviceRequest());
      if (response.data != null) {
        return Temperature.fromJson(response.data);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<HeartRate> getLatestHeartRate() async {
    try {
      final response = await http.get(env.baseUrl + 'lastValue/heartrate',
          queryParameters: await _getDeviceRequest());
      if (response.data != null) {
        return HeartRate.fromJson(response.data);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<OxygenLevel> getLatestOxygenLevel() async {
    try {
      final response = await http.get(env.baseUrl + 'lastValue/bloodOxygen',
          queryParameters: await _getDeviceRequest());
      if (response.data != null) {
        return OxygenLevel.fromJson(response.data);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<DailySteps> getLatestSteps() async {
    try {
      final response = await http.get(env.baseUrl + 'lastValue/dailySteps',
          queryParameters: await _getDeviceRequest());
      if (response.data != null) {
        return DailySteps.fromJson(response.data);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<BloodPressure> getLatestBloodPressure() async {
    try {
      final response = await http.get(env.baseUrl + 'lastValue/bloodPressure',
          queryParameters: await _getDeviceRequest());
      if (response.data != null) {
        return BloodPressure.fromJson(response.data);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<Calories> getLatestCalories() async {
    try {
      final response = await http.get(env.baseUrl + 'lastValue/calories',
          queryParameters: await _getDeviceRequest());
      if (response.data != null) {
        return Calories.fromJson(response.data);
      }
    } catch (error) {
      throw error;
    }
  }
}
