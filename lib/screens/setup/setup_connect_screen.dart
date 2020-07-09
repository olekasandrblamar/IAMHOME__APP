import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifeplus/helpers/errordialog_popup.dart';
import 'package:lifeplus/screens/setup/setup_active_screen.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;
import 'package:permission_handler/permission_handler.dart';

class SetupConnectScreen extends StatefulWidget {
  @override
  _SetupConnectScreenState createState() => _SetupConnectScreenState();
}

class _SetupConnectScreenState extends State<SetupConnectScreen> {
  final TextEditingController _deviceIdController = TextEditingController();

  var _isLoading = false;
  var _deviceIdNumber = '';

  static const platform = const MethodChannel('samples.flutter.dev/battery');

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

      this._connectDevice();
    } catch (error) {
      showErrorDialog(context, error.toString());
    }
  }

  Future<void> _connectDevice() async {

    try {
      final String result = await platform.invokeMethod('connectDevice');
      print("Got response "+result);
    } on PlatformException catch (e) {
    }
    setState(() {
      _isLoading = false;
    });

    //TODO - Add code to check the result and add actions based on that

    _redirectTo();
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
                child: FadeInImage(
                  placeholder: AssetImage(
                    'assets/images/placeholder.jpg',
                  ),
                  image: AssetImage(
                    'assets/images/2.png',
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
                    'Enter last 4 characters of device ID',
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
              //     color: Color(0XFF6C63FF),
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
