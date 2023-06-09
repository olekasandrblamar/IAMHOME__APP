import 'dart:convert';

import 'package:ceras/config/background_fetch.dart';
import 'package:ceras/screens/setup/setup_home_screen.dart';
import 'package:ceras/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import 'package:ceras/constants/route_paths.dart' as routes;

class SetupUpgradeScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  SetupUpgradeScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _SetupUpgradeScreenState createState() => _SetupUpgradeScreenState();
}

class _SetupUpgradeScreenState extends State<SetupUpgradeScreen> with SingleTickerProviderStateMixin  {
  bool isUpgrading = false;
  AnimationController _controller;
  String upgradeMessage = '';
  bool upgradeSuccess = false;
  final eventChannel = EventChannel('ceras.iamhome.mobile/device_upgrade');


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _upgradeDevice();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    setState(() {
      upgradeMessage = 'Upgrade in progress';
    });

    Future.delayed(Duration(seconds: 1), () {
      _controller.repeat(min: 0,max: 1);
      //Add a timeout error
    });
    super.initState();
  }

  void _setIsUpgrading(bool upgradeInProgress) {
    if (mounted) {
      setState(() {
        isUpgrading = upgradeInProgress;
      });
    }
  }

  void _upgradeDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final connectionInfo = prefs.getString('watchInfo');
    if (connectionInfo != null) {
      _setIsUpgrading(true);
      eventChannel.receiveBroadcastStream({'connectionInfo': connectionInfo}).listen((event) {
        final returnData = json.decode(event);
        if(returnData['status']=='Success'){
          upgradeSuccess = true;
          developer.log('Upgrade at $upgradeSuccess ${returnData['message']}');
          setState(() {
            upgradeMessage = returnData['message'];
          });
        }else if(returnData['status']=='Error'){
          _showUpgradeFail(returnData['message']);
          upgradeSuccess = false;
          developer.log('Upgrade error ${returnData['message']}');
        }
      }, onError: (dynamic error) {
        _showUpgradeFail(error);
        upgradeSuccess = true;
      },onDone: () {
        developer.log('Upgrade complete $upgradeSuccess');
        _setIsUpgrading(false);
        if(upgradeSuccess){
          _showUpgradeSuccess();
        }
      });

      // final upgrade = BackgroundFetchData.platform.invokeMethod(
      //   'upgradeDevice',
      //   <String, dynamic>{'connectionInfo': connectionInfo},
      // );
      //
      // await upgrade.then((value) {
      //   if ((value as String) == 'Success') {
      //     Future.delayed(Duration(seconds: 5),(){
      //       _setIsUpgrading(false);
      //       _showUpgradeSuccess();
      //     });
      //   } else {
      //     _showUpgradeFail('Upgrade to device is unsuccessfull');
      //   }
      // }, onError: (error) {
      //   _showUpgradeFail(error);
      // });

      //If we don't get response in 30 seconds close the loading
      // Future.delayed(Duration(seconds: 240), () {
      //   _setIsUpgrading(false);
      //   _showUpgradeFail('Upgrade to device is unsuccessfull');
      //   //Add a timeout error
      // });
    }
  }

  void _showUpgradeSuccess() {
    developer.log('Displaying upgrade complete');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Success',
          ),
          content: Text('Successfully upgraded your device to latest version'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();

                _navigateToHomePage();
              },
              child: Text(
                'Ok',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpgradeFail(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Upgrade Failed',
          ),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();

                _upgradeDevice();
              },
              child: Text(
                'Retry',
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();

                _navigateToHomePage();
              },
              child: Text(
                'Ok',
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHomePage() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => SetupHomeScreen(),
          settings: const RouteSettings(name: routes.SetupHomeRoute),
        ),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Upgrading Device'),
        // ),
        backgroundColor: AppTheme.white,
        body: Container(
          width: double.infinity,
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
                      child: RotationTransition(
                        turns: Tween(begin: 1.0, end: 0.0).animate(_controller),
                        child: Image.asset(
                          'assets/images/upgrading.png',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        upgradeMessage,
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
                        'Please do not close the app',
                        textAlign: TextAlign.center,
                        style: AppTheme.subtitle,
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    !isUpgrading
                        ? Container(
                            width: 200,
                            height: 75,
                            padding: EdgeInsets.all(10),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.5),
                              ),
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              onPressed: () => _upgradeDevice(),
                              child: Text(
                                'Retry Upgrade',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 0,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
