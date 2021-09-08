import 'dart:convert';
import 'dart:io';

import 'package:package_info/package_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateDeviceInfo() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  Map<String, dynamic> deviceData = {};

  if (Platform.isIOS) {
    try {
      final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceData = {
        'deviceInfo': {
          'name': iosDeviceInfo.name,
          'systemName': iosDeviceInfo.systemName,
          'systemVersion': iosDeviceInfo.systemVersion,
          'model': iosDeviceInfo.model,
          'localizedModel': iosDeviceInfo.localizedModel,
          'identifierForVendor': iosDeviceInfo.identifierForVendor,
          'isPhysicalDevice': iosDeviceInfo.isPhysicalDevice,
          'utsname.sysname': iosDeviceInfo.utsname.sysname,
          'utsname.nodename': iosDeviceInfo.utsname.nodename,
          'utsname.release': iosDeviceInfo.utsname.release,
          'utsname.version': iosDeviceInfo.utsname.version,
          'utsname.machine': iosDeviceInfo.utsname.machine,
        },
        'appInfo': {
          'appName': packageInfo.appName,
          'packageName': packageInfo.packageName,
          'version': packageInfo.version,
          'buildNumber': packageInfo.buildNumber,
        }
      };
    } on Exception catch (e) {
      deviceData = {};
    }
  }

  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    deviceData = <String, dynamic>{
      'deviceInfo': {
        'version.securityPatch': androidDeviceInfo.version.securityPatch,
        'version.sdkInt': androidDeviceInfo.version.sdkInt,
        'version.release': androidDeviceInfo.version.release,
        'version.previewSdkInt': androidDeviceInfo.version.previewSdkInt,
        'version.incremental': androidDeviceInfo.version.incremental,
        'version.codename': androidDeviceInfo.version.codename,
        'version.baseOS': androidDeviceInfo.version.baseOS,
        'board': androidDeviceInfo.board,
        'bootloader': androidDeviceInfo.bootloader,
        'brand': androidDeviceInfo.brand,
        'device': androidDeviceInfo.device,
        'display': androidDeviceInfo.display,
        'fingerprint': androidDeviceInfo.fingerprint,
        'hardware': androidDeviceInfo.hardware,
        'host': androidDeviceInfo.host,
        'id': androidDeviceInfo.id,
        'manufacturer': androidDeviceInfo.manufacturer,
        'model': androidDeviceInfo.model,
        'product': androidDeviceInfo.product,
        'supported32BitAbis': androidDeviceInfo.supported32BitAbis,
        'supported64BitAbis': androidDeviceInfo.supported64BitAbis,
        'supportedAbis': androidDeviceInfo.supportedAbis,
        'tags': androidDeviceInfo.tags,
        'type': androidDeviceInfo.type,
        'isPhysicalDevice': androidDeviceInfo.isPhysicalDevice,
        'androidId': androidDeviceInfo.androidId,
        'systemFeatures': androidDeviceInfo.systemFeatures,
      },
      'appInfo': {
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      }
    };
  }

  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("userDeviceInfo", json.encode(deviceData));

  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setString("userDeviceInfo", json.encode(deviceData));
}
