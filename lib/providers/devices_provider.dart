import 'dart:io';
import 'dart:convert';

import 'package:ceras/config/env.dart';
import 'package:ceras/models/currentversion_model.dart';
import 'package:ceras/models/promo_model.dart';
import 'package:ceras/models/profile_model.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/tracker_model.dart';
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

  // This method migrates the saved device data from old model to new device model
  static Future<void> migrateDeviceModel() async {
    var devices = await DevicesProvider.loadDevices();
    if(devices.isNotEmpty) {
      devices.forEach((device) {
        var deviceName = device.deviceMaster['name'] as String;
        device.watchInfo.deviceType = deviceName;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceData', json.encode(devices));
    }
  }

  static Future<List<DevicesModel>> loadDevices() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var prefData = prefs.getString('deviceData');

    // prefs.clear();

    if (prefData == null) {
      return [];
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

    return formattedData;
  }

  Future<List<DevicesModel>> getDevicesData() async {
    _deviceData = await loadDevices();
    notifyListeners();

    return _deviceData;
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

    var deviceData = await getDevicesData();

    // if (Platform.isIOS) {
    //   macAddress = prefs.getString('device_macid');
    // } else {
    //   var watchInfo =
    //       json.decode(prefs.getString('watchInfo')) as Map<String, dynamic>;
    //   macAddress = WatchModel.fromJson(watchInfo).deviceId;
    // }

    if(deviceData.isNotEmpty){
      macAddress = deviceData[0].watchInfo.deviceId;
    }

    return macAddress.replaceAll(":", "");
  }

  Future<Map<String, dynamic>> _getDeviceRequest() async {
    var devices = await getDevicesData();
    return {"deviceList": devices.map((e) => e.watchInfo.deviceId).join(",")};
  }

  Future<List<Tracker>> getDeviceTrackers() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/master/deviceTrackers',
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        print("Got ${response.data}");

        final formattedData = <Tracker>[];

        response.data.forEach(
          (data) {
            if (data != null && data['active'] && data['mobileDisplay']) {
              formattedData.add(
                Tracker.fromJson(data),
              );
            }
          },
        );

        return formattedData;
      }
    } catch (error) {
      print("Error on Device Tracker Data" + error.toString());
    }
  }

  Future<TrackerData> getLatestTrackerData(Tracker trackerMasterData) async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/lastValue/' + trackerMasterData.trackerName,
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        print("Got ${response.data}");

        final responseData = response.data;

        final dataValue =
            responseData[trackerMasterData.trackerValues[0].dataPropertyName];

        var formattedData = {
          'data': dataValue != null ? dataValue : 0,
          'deviceId': responseData['deviceId'],
          'measureTime': responseData['measureTime'],
        };

        return TrackerData.fromJson(formattedData);
      }
    } catch (error) {
      print("Error on temp" + error.toString());
      return null;
    }
  }

  Future<TrackerDataMultiple> getLatestTrackerMultipleData(
      Tracker trackerMasterData) async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/lastValue/' + trackerMasterData.trackerName,
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        print("Got ${response.data}");

        final responseData = response.data;

        final dataValue1 =
            responseData[trackerMasterData.trackerValues[0].dataPropertyName];
        final dataValue2 =
            responseData[trackerMasterData.trackerValues[1].dataPropertyName];

        var formattedData = {
          'data1': dataValue1 != null ? dataValue1 : 0,
          'data2': dataValue2 != null ? dataValue2 : 0,
          'deviceId': responseData['deviceId'],
          'measureTime': responseData['measureTime'],
        };

        return TrackerDataMultiple.fromJson(formattedData);
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

  Future<bool> removeDevice(int index) async {
    _watchInfo = null;
    _deviceData.removeAt(index);

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('watchInfo');
    await prefs.setString('deviceData', json.encode(_deviceData));

    return true;
    // NavigationService.goBackHome();
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

  findDevice(deviceId) {

  }
}
