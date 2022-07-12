import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/helpers/errordialog_popup.dart';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
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

class SetupScaleBluetoothScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  SetupScaleBluetoothScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _SetupScaleBluetoothScreenState createState() =>
      _SetupScaleBluetoothScreenState();
}

class _SetupScaleBluetoothScreenState extends State<SetupScaleBluetoothScreen> {
  final TextEditingController _deviceIdController = TextEditingController();

  DevicesModel _deviceData = null;
  var _deviceType = '';
  var _displayImage = '';
  var _isLoading = false;
  var _deviceIdNumber = '';
  String connectionInfo;
  String _deviceTag = '';
  int _selectStep = 1;

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
          _deviceIdNumber = _deviceIdController.text.toUpperCase();
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
          'deviceId': _deviceIdNumber.toUpperCase(),
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
            'Authentication Failed!',
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
    Navigator.of(context).pop();
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
          child: _selectStep == 1
              ? setupBluetoothIntro(context)
              : setupBluetooth(context),
        ),
      ),
    );
  }

  Column setupBluetoothIntro(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            bottom: 5.0,
          ),
          child: Text(
            'Step 1 of 2',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.18,
              color: Colors.red,
            ),
          ),
        ),
        SizedBox(
          height: 25,
        ),
        Container(
          width: double.infinity,
          child: Text(
            'Your device ID is the last 4 digits on the back of the box',
            // overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTheme.title,
          ),
        ),
        SizedBox(
          height: 25,
        ),
        Card(
          elevation: 5.0,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 250.0,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    'assets/images/bluetooth_scale_into.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
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
                    child: Text(
                      'Next',
                    ),
                    onPressed: () {
                      setState(() {
                        _selectStep = 2;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Column setupBluetooth(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            bottom: 5.0,
          ),
          child: Text(
            'Step 2 of 2',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.18,
              color: Colors.red,
            ),
          ),
        ),
        SizedBox(
          height: 25,
        ),
        Container(
          width: double.infinity,
          child: Text(
            'While Standing on the device please enter your device ID',
            // overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTheme.title,
          ),
        ),
        SizedBox(
          height: 25,
        ),
        Card(
          elevation: 5.0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: PinCodeTextField(
                    appContext: context,
                    // pastedTextStyle: TextStyle(
                    //   color: Colors.green.shade600,
                    //   fontWeight: FontWeight.bold,
                    // ),
                    length: 4,
                    obscureText: false,
                    obscuringCharacter: '*',
                    validator: (v) {
                      if (v.length < 4) {
                        return '';
                      } else {
                        return null;
                      }
                    },
                    textCapitalization: TextCapitalization.characters,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 60,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                    ),
                    cursorColor: Colors.black,
                    animationType: AnimationType.fade,
                    animationDuration: Duration(milliseconds: 300),
                    textStyle: TextStyle(fontSize: 20, height: 1.6),
                    enableActiveFill: true,
                    // errorAnimationController: errorController,
                    controller: _deviceIdController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    boxShadows: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (v) {
                      print('Completed');
                      _onChangeDeviceIdInput(v);
                    },
                    // onTap: () {
                    //   print("Pressed");
                    // },
                    onChanged: (value) {
                      print(value);
                      // if (value.length > 4) {
                      //   _onChangeDeviceIdInput(value);
                      // }
                    },
                    beforeTextPaste: (text) {
                      print('Allowing to paste $text');
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // SizedBox(
                //   height: 20,
                // ),
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
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/placeholder.jpg'),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: FittedBox(
                    child: Text(
                      (_deviceData?.deviceMaster != null &&
                              _deviceData?.deviceMaster['displayName'] != null)
                          ? _deviceData?.deviceMaster['displayName'] +
                              ' Tracker'
                          : '',
                      textAlign: TextAlign.center,
                      style: AppTheme.title,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
