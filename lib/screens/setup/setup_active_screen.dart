import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lifeplus/config/background_fetch.dart';
import 'package:lifeplus/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupActiveScreen extends StatefulWidget {
  @override
  _SetupActiveScreenState createState() => _SetupActiveScreenState();
}

class _SetupActiveScreenState extends State<SetupActiveScreen> {
  String last_Updated = null;

  @override
  void initState() {
    _changeLastUpdated();
    _syncDataFromDevice();
    super.initState();
  }

  void _changeLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('last_sync');
    setState(() {
      last_Updated = lastUpdate;
    });
//    SharedPreferences.getInstance().then((pref) {
//      setState(() {
//        last_Updated = pref.getString("last_sync");
//      });
//    });
  }

  void _syncDataFromDevice() async {
    await syncDataFromDevice();
    await _changeLastUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(children: [
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
          Expanded(
            child: Center(child: Text('')),
          )
        ]),
        actions: <Widget>[
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.headset_mic),
            onPressed: () {},
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Device Found',
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
                'Last connected ${last_Updated}.',
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
                color: Color(0XFF6C63FF),
                textColor: Colors.white,
                child: Text(
                  'SyncData',
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
