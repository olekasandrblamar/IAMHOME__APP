import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/screens/setup/connection_wifi.dart';
import 'package:ceras/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SetupScaleWifiScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  SetupScaleWifiScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _SetupScaleWifiScreenState createState() => _SetupScaleWifiScreenState();
}

class _SetupScaleWifiScreenState extends State<SetupScaleWifiScreen> {
  DevicesModel _deviceData = null;
  var _deviceType = '';
  var _displayImage = '';
  String _deviceTag = '';

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
    super.dispose();
  }

  void _redirectTo() {
    Navigator.of(context).pop();
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
        child: SingleChildScrollView(child: setupWifiInto(context)),
      ),
    );
  }

  Column setupWifiInto(BuildContext context) {
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
        Container(
          width: double.infinity,
          child: Text(
            '- Connecting via 2.4Ghz wifi will allow you to weight yourself without opening the ceras app daily.',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTheme.title,
          ),
        ),
        Container(
          width: double.infinity,
          child: Text(
            '- Please note that it may not work with some wifi networks.',
            overflow: TextOverflow.ellipsis,
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
                  constraints: BoxConstraints(
                    maxHeight: 250.0,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: 250.0,
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      'assets/images/bluetooth.svg',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
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
                      'Ok',
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ConnectionWifiScreen(
                              routeArgs: {
                                'displayImage': _displayImage,
                                'deviceData': _deviceData,
                              },
                            ),
                            settings: const RouteSettings(
                                name: routes.ConnectionWifiRoute),
                          ),
                          (Route<dynamic> route) => false);
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
}
