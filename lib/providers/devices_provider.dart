import 'dart:io';
import 'dart:convert';

import 'package:ceras/config/env.dart';
import 'package:ceras/models/currentversion_model.dart';
import 'package:ceras/models/promo_model.dart';
import 'package:ceras/models/profile_model.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/terra_devices_model.dart';
import 'package:ceras/models/tracker_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ceras/config/http.dart';
import 'package:ceras/config/navigation_service.dart';
import 'package:ceras/data/terra_device_data.dart';
import 'dart:io' show Platform;

class DevicesProvider extends ChangeNotifier {
  final http = HttpClient().http;

  final mobileDataHttp = HttpClient().mobileDataHttp;

  List<dynamic> _deviceData = [];
  WatchModel _watchInfo;

  bool _b500BluetoothConnection = false;
  bool _b500WifiConnection = false;

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
      final formattedData = [];
      ////////////Terra Devices/////////
      if(Platform.isAndroid) {
        for (int i = 0; i < TERRA_DEVICE_DATA_ANDROID.length; i++) {
          formattedData.add(TERRA_DEVICE_DATA_ANDROID[i]);
        }
      }else if(Platform.isIOS) {
        for (int i = 0; i < TERRA_DEVICE_DATA_IOS.length; i++) {
          formattedData.add(TERRA_DEVICE_DATA_IOS[i]);
        }
      }
      /////////////////////
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
    if (devices.isNotEmpty) {
      devices.forEach((device) {
        var deviceName = device.deviceMaster['name'] as String;
        device.watchInfo.deviceType = deviceName;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deviceData', json.encode(devices));
    }
  }

  static Future<List<dynamic>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var prefData = prefs.getString('deviceData');

    // prefs.clear();

    if (prefData == null) {
      return [];
    }

    // print("Got prefs data ${prefData}");

    final List<dynamic> formattedData = [];
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

  Future<List<dynamic>> getDevicesData() async {
    _deviceData = await loadDevices();
    notifyListeners();

    return _deviceData;
  }

  Future<dynamic> getDeviceData(int index) async {
    dynamic deviceData = _deviceData[index];
    return deviceData;
  }

  void setDeviceData(dynamic deviceData) async {
    final prefs = await SharedPreferences.getInstance();
    final prefData = prefs.getString('deviceData');

    final List<dynamic> formattedData = [];

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

    if (deviceData.isNotEmpty) {
      macAddress = deviceData[0].watchInfo.deviceId;
    }

    return macAddress.replaceAll(":", "");
  }

  Future<Map<String, dynamic>> _getDeviceRequest() async {
    var devices = await getDevicesData();
    var deviceRequestData = devices.map((e) => e.watchInfo.deviceId).join(",");
    var b300Address =
        await (await SharedPreferences.getInstance()).getString("device_macid");
    if (b300Address != null) {
      deviceRequestData = b300Address + ",$deviceRequestData";
    }
    var deviceRequest = {"deviceList": deviceRequestData};
    print('Getting trackers for $deviceRequest');
    return deviceRequest;
  }

  Future<Map<String, dynamic>> _getDeviceTypesRequest() async {
    var devices = await getDevicesData();
    var deviceRequestData =
        devices.map((e) => e.deviceMaster['name']).join(",");
    // var b300Address = await (await SharedPreferences.getInstance()).getString("device_macid");
    // if(b300Address != null){
    //   deviceRequestData=b300Address+",$deviceRequestData";
    // }
    var deviceRequest = {"deviceTypes": deviceRequestData};
    print('Getting trackers for $deviceRequest');
    return deviceRequest;
  }

  Future<List<Tracker>> getDeviceTrackers() async {
    try {
      final baseUrl = await _baseUrl;
      final response = await mobileDataHttp.get(
        baseUrl + '/master/deviceTrackers',
        queryParameters: await _getDeviceTypesRequest(),
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
      var trackerUrl = baseUrl + '/lastValue/' + trackerMasterData.trackerName;
      print('Getting  value from $trackerUrl');
      final response = await mobileDataHttp.get(
        trackerUrl,
        queryParameters: await _getDeviceRequest(),
      );

      if (response.data != null) {
        final responseData = response.data;
        print(
            "Got ${response.data} and reading property ${trackerMasterData.trackerValues[0].dataPropertyName} value ${responseData[trackerMasterData.trackerValues[0].dataPropertyName]}");

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
        trackerMasterData.trackerValues.sort(
            (tracker1, tracker2) => tracker1.order.compareTo(tracker2.order));
        print(
            'property 1 ${trackerMasterData.trackerValues[0].dataPropertyName} property2 ${trackerMasterData.trackerValues[1].dataPropertyName}');
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

  findDevice(deviceId) {}

  updateB500BluetoothConnection(bool connection) async {
    _b500BluetoothConnection = connection;

    notifyListeners();
  }

  updateB500WifiConnection(bool connection) async {
    _b500WifiConnection = connection;

    notifyListeners();
  }

  bool getB500BluetoothConnection() {
    return _b500BluetoothConnection;
  }

  bool getB500WifiConnection() {
    return _b500WifiConnection;
  }
}
