import 'package:ceras/config/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:ceras/config/background_fetch.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/apppermissions_widget.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

class SetupActiveScreen extends StatefulWidget {
  @override
  _SetupActiveScreenState createState() => _SetupActiveScreenState();
}

class _SetupActiveScreenState extends State<SetupActiveScreen> {
  String _lastUpdated = null;
  String _deviceType = null;

  @override
  void initState() {
    _changeLastUpdated();
    _syncDataFromDevice();
    super.initState();
  }

  void _changeLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final lastUpdate = prefs.getString('last_sync');
    final deviceType = prefs.getString('deviceType');
    print("Last updated at ${lastUpdate}");
    setState(() {
      _lastUpdated = lastUpdate;
      _deviceType = deviceType;
    });
  }

  void _syncDataFromDevice() async {
    await syncDataFromDevice();
    await _changeLastUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final _appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: SetupAppBar(),
      backgroundColor: AppTheme.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  _deviceType == 'Watch'
                      ? 'assets/images/Picture1.jpg'
                      : 'assets/images/Picture2.jpg',
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
                _appLocalization.translate('setup.active.devicefound'),
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
                _appLocalization.translate('setup.active.lastconnected') +
                    ' ${_lastUpdated}.',
                textAlign: TextAlign.center,
                style: AppTheme.subtitle,
              ),
            ),
            SizedBox(
              height: 25,
            ),
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
                  _appLocalization.translate('setup.active.syncdata'),
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                onPressed: () async {
//                  return Navigator.of(context).pushReplacementNamed(
//                    routes.SetupHomeRoute,
//                  );
                  await _syncDataFromDevice();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
