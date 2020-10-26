import 'dart:convert';

import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/screens/auth/login_screen.dart';
import 'package:ceras/screens/data_screen.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupHomeScreen extends StatefulWidget {
  @override
  _SetupHomeScreenState createState() => _SetupHomeScreenState();
}

class _SetupHomeScreenState extends State<SetupHomeScreen> {
  DevicesModel _deviceData = null;

  @override
  void initState() {
    // TODO: implement initState

    loadData();

    super.initState();
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final prefData = prefs.getString('deviceData');
    if (prefData != null) {
      final deviceData =
          DevicesModel.fromJson(json.decode(prefData) as Map<String, dynamic>);

      setState(() {
        _deviceData = deviceData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var imageData = (_deviceData?.deviceMaster != null &&
            _deviceData?.deviceMaster['displayImage'] != null)
        ? _deviceData?.deviceMaster['displayImage']
        : null;

    return Scaffold(
      appBar: SetupAppBar(name: 'My Devices'),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: _deviceData != null
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            height: 150,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(15),
                                  child: Container(
                                    height: 100.0,
                                    width: 100.0,
                                    child: FadeInImage(
                                      placeholder: AssetImage(
                                        'assets/images/placeholder.jpg',
                                      ),
                                      image: imageData != null
                                          ? NetworkImage(
                                              imageData,
                                            )
                                          : AssetImage(
                                              'assets/images/placeholder.jpg',
                                            ),
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      fadeInDuration:
                                          Duration(milliseconds: 200),
                                      fadeInCurve: Curves.easeIn,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        (_deviceData?.deviceMaster != null &&
                                                _deviceData?.deviceMaster[
                                                        'displayName'] !=
                                                    null)
                                            ? _deviceData?.deviceMaster[
                                                    'displayName'] +
                                                ' Device'
                                            : '',
                                        style: AppTheme.title,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          onTap: () => {
                            Navigator.of(context).pushNamed(
                              routes.SetupActiveRoute,
                            ),
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            height: 150,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(15),
                                  child: Image.asset(
                                    'assets/images/AddNewDeviceDefault.png',
                                    height: 75,
                                    width: 75,
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    'Add New Device',
                                    style: AppTheme.title,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () => {
                            Navigator.of(context).pushNamed(
                              routes.SetupDevicesRoute,
                            ),
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: _deviceData != null
          ? SafeArea(
              bottom: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 90,
                    padding: EdgeInsets.all(20),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.5),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text('Access Health Data'),
                      onPressed: () {
                        // return Navigator.of(context).pushReplacementNamed(
                        //   routes.LoginRoute,
                        // );

                        return Navigator.of(context).push(
                          MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return DataScreen();
                            },
                            fullscreenDialog: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: 0,
            ),
    );
  }
}
