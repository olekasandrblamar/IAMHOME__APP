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
import 'package:terra_flutter_bridge/terra_flutter_bridge.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TerraProvider {
  bool _initialised = false;
  bool _connected = false;
  bool _daily = false;
  String _testText;

  Future<void> initTerraFunctionState() async {

    bool initialised = false;
    bool connected = false;
    bool daily = false;
    String testText;
    Connection c = Connection.samsung;
    /*
    To use the Samsung integration, the user needs Health Platform downloaded on their device and their Samsung Health Account linked to Health Platform. This can be done by going on Samsung Health -> Profile -> Settings -> Connected Services -> Health Platform and giving Health Platform access to their data.
    */

    // Function messages may fail, so we use a try/catch Exception.
    // We also handle the message potentially returning null.
    // USE YOUR OWN CATCH BLOCKS
    // HAVING ALL FUNCTIONS IN THE SAME CATCH IS NOT A GOOD IDEA
    try {
      DateTime now = DateTime.now().toUtc();
      DateTime lastMidnight = DateTime(now.year, now.month, now.day);
      // Fluttertoast.showToast(
      //   msg: "trying integration init",
      //   toastLength: Toast.LENGTH_SHORT,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.black,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );
      initialised =
          await TerraFlutter.initTerra("ceras-dev-y5kN5MDRKv", "67d93d7e-09f1-4402-b5ad-fb437f3b4628") ??
              false;
      String str;
      if(_initialised) str = "true";
      else str = "false";
      // Fluttertoast.showToast(
      //   msg: "Did integration init:" + str,
      //   toastLength: Toast.LENGTH_SHORT,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.black,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );


      connected = await TerraFlutter.initConnection(c, "a3e614f4481dbb92cca6d2957bde3f71951551e726710c2f7b88d7c7c5174562", false, []) ??
          false;

      if(_connected) str = "true";
      else str = "false";
      // Fluttertoast.showToast(
      //   msg: "Is integration connected:" + str,
      //   toastLength: Toast.LENGTH_SHORT,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.black,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );

      testText = await TerraFlutter.getUserId(c) ?? "1234";

      // Fluttertoast.showToast(
      //   msg: "User id:" + testText,
      //   toastLength: Toast.LENGTH_SHORT,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.black,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );

      daily = await TerraFlutter.getDaily(
          c, lastMidnight, now) ??
          false;
      daily = await TerraFlutter.getAthlete(c) ?? false;
      daily = await TerraFlutter.getMenstruation(
          c, DateTime(2022, 9, 25), DateTime(2022, 9, 30)) ??
          false;
      daily = await TerraFlutter.getNutrition(
          c, DateTime(2022, 7, 25), DateTime(2022, 7, 26)) ??
          false;
      daily = await TerraFlutter.getSleep(
          c, now.subtract(Duration(days: 1)), now) ??
          false;
      daily = await TerraFlutter.getActivity(
          c, DateTime(2022, 7, 25), DateTime(2022, 7, 26)) ??
          false;

      // if(_daily) str = "true";
      // else str = "false";
      // Fluttertoast.showToast(
      //   msg: "Requested daily webhook for integration:" + str,
      //   toastLength: Toast.LENGTH_SHORT,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.black,
      //   textColor: Colors.white,
      //   fontSize: 16.0,
      // );
    } on Exception catch (e) {
      // print('error caught: $e');
      testText = "Some exception went wrong";
      initialised = false;
      connected = false;
      daily = false;
      Fluttertoast.showToast(
        msg: testText,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );

    }
    // Fluttertoast.showToast(
    //   msg: "No exception occured",
    //   toastLength: Toast.LENGTH_SHORT,
    //   timeInSecForIosWeb: 1,
    //   backgroundColor: Colors.black,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    // );
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _initialised = initialised;
      _connected = connected;
      _daily = daily;
      _testText = testText;
    });


  }
/////////////////////////////////////////////////////////
}
