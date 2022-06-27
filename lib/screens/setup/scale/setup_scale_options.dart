import 'package:cached_network_image/cached_network_image.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/screens/auth/login_screen.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/nodata_widget.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SetupScaleOptionsScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  SetupScaleOptionsScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _SetupScaleOptionsScreenState createState() =>
      _SetupScaleOptionsScreenState();
}

class _SetupScaleOptionsScreenState extends State<SetupScaleOptionsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    bottom: 5.0,
                  ),
                  child: Text(
                    'Connection Options:',
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppTheme.title,
                  ),
                ),
                bluetoothConnect(context),
                wifiConnect(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container bluetoothConnect(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxHeight: 300.0,
              ),
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                'assets/images/bluetooth.svg',
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Connect via Bluetooth',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTheme.title,
              ),
            ),
            Container(
              width: 200,
              height: 75,
              padding: EdgeInsets.all(10),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.5),
                ),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: () async {
                  return Navigator.of(context).pushNamed(
                    routes.SetupScaleBluetoothRoute,
                    arguments: {...widget.routeArgs},
                  );
                },
                child: Text(
                  'Connect Now',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Container wifiConnect(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxHeight: 300.0,
              ),
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                'assets/images/wifi.svg',
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Connect via Wifi',
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
                'Optional',
                textAlign: TextAlign.center,
                style: AppTheme.subtitle,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                // vertical: 5.0,
                horizontal: 35.0,
              ),
              child: Text(
                'Please be sure you have your network information and wifi password ',
                textAlign: TextAlign.center,
                style: AppTheme.subtitle,
              ),
            ),
            Container(
              width: 200,
              height: 75,
              padding: EdgeInsets.all(10),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.5),
                ),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: () async {},
                child: Text(
                  'Connect Now',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}
