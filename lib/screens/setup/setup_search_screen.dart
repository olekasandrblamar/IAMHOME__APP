import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lifeplus/theme.dart';
import 'dart:math';

import 'package:lifeplus/constants/route_paths.dart' as routes;

class SetupSearchScreen extends StatefulWidget {
  @override
  _SetupSearchScreenState createState() => _SetupSearchScreenState();
}

class _SetupSearchScreenState extends State<SetupSearchScreen>
    with SingleTickerProviderStateMixin {
  String showDisplay = 'Found';
  AnimationController rotationController;

  List<bool> _selections = [true, false, false];

  @override
  void initState() {
    rotationController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    // ..addStatusListener((status) {
    //     if (status == AnimationStatus.completed) {
    //       rotationController.repeat();
    //     }
    //   });

    rotationController.forward();

    _searchDevices();

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    color: showDisplay == 'Found' ? Colors.red : null,
                    child: Text('Record'),
                    onPressed: () {
                      setState(() {
                        showDisplay = 'Found';
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: RaisedButton(
                      color: showDisplay == 'NotFound' ? Colors.red : null,
                      child: FittedBox(child: Text('Device Not Found')),
                      onPressed: () {
                        setState(() {
                          showDisplay = 'NotFound';
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: RaisedButton(
                    color:
                        showDisplay == 'BluetoothNotFound' ? Colors.red : null,
                    child: FittedBox(
                      child: Text('Bluetooth Not Found'),
                    ),
                    onPressed: () {
                      setState(() {
                        showDisplay = 'BluetoothNotFound';
                      });
                    },
                  ),
                )
              ],
            ),
            // ToggleButtons(
            //   selectedColor: Colors.red,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text('Record'),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text('Device Not Found'),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Text('Bluetooth Not Found'),
            //     ),
            //   ],
            //   isSelected: _selections,
            //   onPressed: (int index) {
            //     setState(
            //       () {
            //         for (int indexBtn = 0;
            //             indexBtn < _selections.length;
            //             indexBtn++) {
            //           if (indexBtn == index) {
            //             _selections[indexBtn] = true;
            //           } else {
            //             _selections[indexBtn] = false;
            //           }
            //         }
            //       },
            //     );
            //   },
            // ),
            SizedBox(
              height: 10,
            ),
            ...showDisplay == 'Found' ? _buildDeviceFound() : [],
            ...showDisplay == 'NotFound' ? _buildNoDeviceFound() : [],
            ...showDisplay == 'BluetoothNotFound'
                ? _buildBluetoothNotFound()
                : [],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text(
                showDisplay == 'Found'
                    ? 'Record'
                    : showDisplay == 'NotFound'
                        ? 'Search'
                        : showDisplay == 'BluetoothNotFound'
                            ? 'Turn Bluetooth'
                            : '',
              ),
              onPressed: () {}),
        ),
      ),
    );
  }

  List<Widget> _buildDeviceFound() {
    Offset _offset = Offset(0.3, -0.9);

    return [
      FittedBox(
        child: Text(
          'Device Found',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      SizedBox(
        height: 5,
      ),
      FittedBox(
        child: Text(
          'Last connected 04/24/2020 12:35 PM',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Expanded(
        child: GestureDetector(
          onTap: () {
            rotationController.reset();
            rotationController.forward();
          },
          child: Transform(
            alignment: FractionalOffset.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0011)
              ..rotateX(_offset.dy)
              ..rotateY(_offset.dx),
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(rotationController),
              child: Image(
                fit: BoxFit.fitHeight,
                image: AssetImage('assets/images/2.png'),
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
    ];
  }

  List<Widget> _buildNoDeviceFound() {
    return [
      FittedBox(
        child: Text(
          'No Device Found',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Expanded(
        child: Image(
          image: AssetImage('assets/images/nodevice.png'),
        ),
      ),
      SizedBox(
        height: 20,
      ),
    ];
  }

  List<Widget> _buildBluetoothNotFound() {
    return [
      FittedBox(
        child: Text(
          'Bluetooth Turned Off',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Expanded(
        child: Image(
          image: AssetImage('assets/images/bluetooth.png'),
        ),
      ),
      SizedBox(
        height: 20,
      ),
    ];
  }
}
