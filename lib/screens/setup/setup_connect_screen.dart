import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/screens/setup/connection_wifi.dart';
import 'package:ceras/screens/setup/setup_connected_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/helpers/errordialog_popup.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/theme.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

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
  String connectionInfo = null;
  String _deviceTag = '';

  var _statusTitle = '';
  var _statusDescription = '';

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

  void showConnectionErrorDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(
          description,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _loadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SimpleDialog(
        title: Text(
          _statusTitle,
          textAlign: TextAlign.center,
        ),
        // backgroundColor: Colors.blueAccent,
        elevation: 4,
        shape: StadiumBorder(
          side: BorderSide(
            style: BorderStyle.none,
          ),
        ),
        children: <Widget>[
          Text(
            _statusDescription,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _connectDevice() async {
    try {
      print('Backing backend call to connect device');
      setState(() {
        _statusTitle = 'Checking Bluetooth';
        _statusDescription = 'Loading.....';
      });

      _loadingDialog();

      // FlutterBlue flutterBlue = FlutterBlue.instance;
      // var checkAvailability = await flutterBlue.isOn;

      var checkAvailability = true;

      if (!checkAvailability) {
        _resetWithError();
        return showConnectionErrorDialog(
          'Bluetooth Settings Failed!',
          'Turn on your bluetooth',
        );
      }

      setState(() {
        _statusTitle = 'Checking Device';
        _statusDescription = 'Finding.....';
      });

      connectionInfo = await platform.invokeMethod(
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

      if (connectionData.deviceFound) {
        setState(() {
          _statusTitle = 'Device Found';
          _statusDescription = 'Verifying.....';
        });

        print("Device found");

        if (connectionData.connected) {
          print("Device connected");
          setState(() {
            _statusTitle = 'Device Found';
            _statusDescription = 'Connecting.....';
          });

          //TODO - Add code to check the result and add actions based on that
          await Provider.of<DevicesProvider>(context, listen: false)
              .saveWatchInfo(connectionData);

          // await Provider.of<WatchProvider>(context, listen: false)
          //     .setDeviceType(_deviceType);
          var watchInfo = json.decode(connectionInfo) as Map<String, dynamic>;

          print("Creating devices model from json");
          var updatedJson = <String, dynamic>{
            'deviceMaster': _deviceData.deviceMaster,
            'watchInfo': watchInfo
          };

          print("created map and converting to json");
          print(updatedJson['watchInfo']);
          var formattedData = DevicesModel.fromJson(updatedJson);

          print("Device master");
          print(formattedData.deviceMaster);
          print("formatted data");
          print(formattedData);

          await Provider.of<DevicesProvider>(context, listen: false)
              .setDeviceData(formattedData);

          setState(() {
            _isLoading = false;
          });

          _redirectTo();
        } else {
          _resetWithError();
          showConnectionErrorDialog(
            'Authentication Failed​!',
            'Unable to Connect device',
          );
        }
      } else {
        _resetWithError();
        showConnectionErrorDialog(
          'Connection Fail!',
          'Device Not Found',
        );
      }
    } on PlatformException catch (e) {
      _resetWithError();
      showConnectionErrorDialog(
        'Connection Fail!',
        'Unable to locate or connect to device',
      );
    }
  }

  void _resetWithError() {
    Navigator.of(context).pop();
    _deviceIdController.text = '';
    setState(
      () {
        _statusTitle = '';
        _statusDescription = '';
        _deviceIdNumber = '';
        _isLoading = false;
      },
    );
  }

  void _redirectTo() {
    Navigator.of(context).pop();
    print('Has wifi ${_deviceData.deviceMaster['wifi']}');
    if(_deviceData.deviceMaster['wifi']==false) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) =>
                SetupConnectedScreen(
                  routeArgs: {
                    'deviceData': _deviceData,
                  },
                ),
            settings: const RouteSettings(name: routes.SetupConnectedRoute),
          ),
              (Route<dynamic> route) => false);
    }else{
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) =>
                ConnectionWifiScreen(
                  routeArgs: {
                    'displayImage': _displayImage,
                    'deviceData': _deviceData,
                  },
                ),
            settings: const RouteSettings(name: routes.ConnectionWifiRoute),
          ),
              (Route<dynamic> route) => false);
    }

    // Navigator.of(context).pushNamed(
    //   routes.SetupConnectedRoute,
    //   arguments: {
    //     'displayImage': _displayImage,
    //   },
    // );
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
                width: double.infinity,
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                ),
                child: Text(
                  // _appLocalization.translate('setup.active.devicefound'),
                  'Device ID located back on device',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.18,
                    color: Colors.red,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Text(
                  'Please Enter Device ID',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: AppTheme.title,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 250.0,
                ),
                padding: const EdgeInsets.all(10.0),
                child: Hero(
                  transitionOnUserGestures: true,
                  tag: _deviceTag,
                  child: CachedNetworkImage(
                    imageUrl: _displayImage,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeInCurve: Curves.easeIn,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/images/placeholder.jpg'),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: FittedBox(
                  child: Text(
                    (_deviceData?.deviceMaster != null &&
                            _deviceData?.deviceMaster['displayName'] != null)
                        ? _deviceData?.deviceMaster['displayName'] + ' Tracker'
                        : '',
                    textAlign: TextAlign.center,
                    style: AppTheme.title,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                  Flexible(
                    flex: 4,
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
                          hintText: '-   -   -   -',
                        ),
                        controller: _deviceIdController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        autofocus: false,
                        onChanged: _onChangeDeviceIdInput,
                        enabled: !_isLoading ? true : false,
                        maxLength: 4,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(),
                  ),
                ],
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
