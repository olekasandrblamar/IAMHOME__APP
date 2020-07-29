import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ceras/theme.dart';
import 'dart:math';

import 'package:ceras/constants/route_paths.dart' as routes;

class SetupSearchScreen extends StatefulWidget {
  @override
  _SetupSearchScreenState createState() => _SetupSearchScreenState();
}

class _SetupSearchScreenState extends State<SetupSearchScreen>
    with SingleTickerProviderStateMixin {
  bool showDisplay = false;

  @override
  void initState() {
    // _searchDevices();

    // TODO: implement initState
    super.initState();
  }

  void _searchDevices() {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });

    // Stop scanning
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.white,
      body: !showDisplay ? _buildNoDeviceFound() : _buildDevicesFound(),
    );
  }

  Widget _buildDevicesFound() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Found Devices',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTheme.title,
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.white,
                  child: InkWell(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 90,
                          padding: const EdgeInsets.all(8.0),
                          child: FadeInImage(
                            placeholder: AssetImage(
                              'assets/images/product-placeholder.png',
                            ),
                            image: AssetImage(
                              'assets/images/Picture2.png',
                            ),
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            fadeInDuration: Duration(milliseconds: 200),
                            fadeInCurve: Curves.easeIn,
                            height: 75,
                            width: 75,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 90,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                  ),
                                  child: Text(
                                    'Device Name',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.subtitle,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                  ),
                                  child: Text(
                                    'Connect',
                                    style: AppTheme.title,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => {
                      Navigator.of(context).pushReplacementNamed(
                        routes.SetupConnectRoute,
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDeviceFound() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 5.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 300.0,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: FadeInImage(
                    placeholder: AssetImage(
                      'assets/images/placeholder.jpg',
                    ),
                    image: AssetImage(
                      'assets/images/devicenotfound.png',
                    ),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeInCurve: Curves.easeIn,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'No Devices Found',
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTheme.title,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    // vertical: 5.0,
                    horizontal: 35.0,
                  ),
                  child: Text(
                    'Check connection and please try again.',
                    textAlign: TextAlign.center,
                    style: AppTheme.subtitle,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 75,
                      padding: EdgeInsets.all(10),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.5),
                        ),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            showDisplay = true;
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
