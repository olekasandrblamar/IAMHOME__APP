import 'dart:convert';

import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/helpers/errordialog_popup.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/screens/setup/setup_active_screen.dart';
import 'package:ceras/theme.dart';
import 'package:provider/provider.dart';

class SetupConnectScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  SetupConnectScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _SetupConnectScreenState createState() => _SetupConnectScreenState();
}

class _SetupConnectScreenState extends State<SetupConnectScreen> {
  final TextEditingController _deviceIdController = TextEditingController();

  DevicesModel _deviceData = null;
  var _deviceType = '';
  var _displayImage = '';
  var _isLoading = false;
  var _deviceIdNumber = '';
  String _deviceTag = '';

  static const platform = MethodChannel('ceras.iamhome.mobile/device');

  @override
  void initState() {
    if (widget.routeArgs != null) {
      _deviceTag = widget.routeArgs['tag'];
      _deviceData = widget.routeArgs['deviceData'];
      _deviceType = widget.routeArgs['deviceType'];
      _displayImage = widget.routeArgs['displayImage'];
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _deviceIdController.dispose();

    super.dispose();
  }

  void _onChangeDeviceIdInput(String pin) async {
    try {
      setState(
        () {
          _deviceIdNumber = _deviceIdController.text;
        },
      );

      if (_deviceIdNumber.length < 4) {
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await _connectDevice();
    } catch (error) {
      _deviceIdController.text = '';
      setState(() {
        _deviceIdNumber = '';
        _isLoading = false;
      });
      showErrorDialog(context, error.toString());
    }
  }

  Future<void> _connectDevice() async {
    try {
      print('Backing backend call to connect device');
      final connectionInfo = await platform.invokeMethod(
        'connectDevice',
        <String, dynamic>{
          'deviceId': _deviceIdNumber,
          'deviceType': _deviceType
        },
      ) as String;

      print('Got response from os code for connection' + connectionInfo);

      final connectionData = WatchModel.fromJson(
        json.decode(connectionInfo) as Map<String, dynamic>,
      );

      //TODO - Add code to check the result and add actions based on that
      await Provider.of<AuthProvider>(context, listen: false)
          .saveWatchInfo(connectionData);

      await Provider.of<AuthProvider>(context, listen: false)
          .setDeviceType(_deviceType);

      await Provider.of<AuthProvider>(context, listen: false)
          .setDeviceData(_deviceData);

      setState(() {
        _isLoading = false;
      });

      _redirectTo();
    } on PlatformException catch (e) {}
  }

  void _redirectTo() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => SetupActiveScreen(),
          settings: const RouteSettings(name: routes.SetupActiveRoute),
        ),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final _appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                  maxHeight: 300.0,
                ),
                padding: const EdgeInsets.all(10.0),
                child: Hero(
                  transitionOnUserGestures: true,
                  tag: _deviceTag,
                  child: FadeInImage(
                    placeholder: AssetImage(
                      'assets/images/placeholder.jpg',
                    ),
                    image: _displayImage != null
                        ? NetworkImage(
                            _displayImage,
                          )
                        : AssetImage(
                            'assets/images/placeholder.jpg',
                          ),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeInCurve: Curves.easeIn,
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: Container(),
                    flex: 2,
                  ),
                  Flexible(
                    child: Container(
                      // margin: EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 35,
                        ),
                        decoration: InputDecoration(
                          // border: OutlineInputBorder(),
                          // labelText: 'Phone',
                          hintText: "-   -   -   -",
                        ),
                        controller: _deviceIdController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        autofocus: false,
                        onChanged: _onChangeDeviceIdInput,
                        enabled: !_isLoading ? true : false,
                        maxLength: 4,
                      ),
                    ),
                    flex: 4,
                  ),
                  Flexible(
                    child: Container(),
                    flex: 2,
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: FittedBox(
                  child: Text(
                    _appLocalization.translate('setup.connect.last4'),
                    textAlign: TextAlign.center,
                    style: AppTheme.title,
                  ),
                ),
              ),
              // SizedBox(
              //   height: 25,
              // ),
              // Container(
              //   width: 150,
              //   height: 75,
              //   padding: EdgeInsets.all(10),
              //   child: RaisedButton(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(4.5),
              //     ),
              //     color: Theme.of(context).primaryColor,
              //     textColor: Colors.white,
              //     child: Text(
              //       'Connect',
              //       style: TextStyle(
              //         fontSize: 14,
              //       ),
              //     ),
              //     onPressed: !_isLoading ? null : () => {},
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
