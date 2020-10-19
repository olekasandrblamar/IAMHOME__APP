import 'package:ceras/config/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

import 'package:ceras/theme.dart';

class DataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _appLocalization = AppLocalizations.of(context);

    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   title: Text(
      //     'My Data',
      //   ),
      //   // actions: <Widget>[
      //   //   SwitchStoreIcon(),
      //   // ],
      // ),
      // backgroundColor: AppTheme.white,
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xffecf3fb),
        ),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              // backgroundColor: Colors.transparent,
              // elevation: 0.0,
              pinned: true,
              expandedHeight: 150.0,
              stretch: true,
              stretchTriggerOffset: 75,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'My Data',
                  // style: TextStyle(
                  //   fontSize: 30,
                  //   fontWeight: FontWeight.bold,
                  //   color: Colors.black,
                  // ),
                ),
                stretchModes: [
                  StretchMode.zoomBackground,
                  // StretchMode.blurBackground,
                  // StretchMode.fadeTitle,
                ],
                background: Image.asset(
                  'assets/images/clouds.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/icons_themometer.png',
                                    height: 25,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Temperature',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: '97.1',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(10, 0),
                                            child: Text(
                                              '°',
                                              //superscript is usually smaller in size
                                              textScaleFactor: 3,
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' F',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('10/08/2020'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('11:42:11 PM'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/icons_heartbeat.png',
                                    height: 25,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Heart Rate',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: '65',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 2),
                                            child: Text(
                                              ' bpm',
                                              //superscript is usually smaller in size
                                              textScaleFactor: 2,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('10/08/2020'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('11:42:11 PM'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/icons_bloodpressure.png',
                                    height: 25,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Blood Pressure',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: '120/80',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 2),
                                            child: Text(
                                              ' mmHg',
                                              //superscript is usually smaller in size
                                              textScaleFactor: 2,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('10/08/2020'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('11:42:11 PM'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/icons_calories.png',
                                    height: 25,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Calories',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '1120',
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          WidgetSpan(
                                            child: Transform.translate(
                                              offset: const Offset(2, 2),
                                              child: Text(
                                                ' Cals',
                                                //superscript is usually smaller in size
                                                textScaleFactor: 2,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('10/08/2020'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('11:42:11 PM'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Card(
                      // color: Color(0xffdfeffd),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.10),
                                  blurRadius: 10.0,
                                  // spreadRadius: 1.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/icons_dailysteps.png',
                                    height: 25,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Steps',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 6,
                                  child: FittedBox(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: '20,002',
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Transform.translate(
                                            offset: const Offset(2, 2),
                                            child: Text(
                                              ' Steps',
                                              //superscript is usually smaller in size
                                              textScaleFactor: 2,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Synced',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('10/08/2020'),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text('11:42:11 PM'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
