import 'package:ceras/config/env.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ceras/config/http.dart';

class DevicesProvider extends ChangeNotifier {
  final http = HttpClient().http;

  Future<void> fetchAllDevices() async {
    try {
      final response = await http.get(
        env.baseUrl + '/master/masterDevices',
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
}
