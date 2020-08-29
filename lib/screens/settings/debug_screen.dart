import 'package:ceras/config/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme.dart';

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool isLoading = true;
  SharedPreferences prefs;

  List data = ['userDeviceInfo', 'watchInfo', 'countryCode', 'language_code'];

  @override
  void initState() {
    _getSharedPref();
    // TODO: implement initState
    super.initState();
  }

  void _getSharedPref() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Device Logs',
        ),
      ),
      backgroundColor: AppTheme.background,
      body: !isLoading
          ? SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: List.generate(
                    data.length,
                    (index) => DebugList(
                      prefs: prefs,
                      value: data[index],
                    ),
                  ),
                ),
              ),
            )
          : Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}

class DebugList extends StatelessWidget {
  final SharedPreferences prefs;
  final String value;

  const DebugList({
    Key key,
    @required this.prefs,
    @required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = prefs.getString(value);

    return Container(
      child: Card(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.title,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                info ?? '--',
                style: AppTheme.subtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
