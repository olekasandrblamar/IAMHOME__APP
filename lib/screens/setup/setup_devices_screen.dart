import 'dart:collection';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/screens/auth/login_screen.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/nodata_widget.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ceras/config/http.dart';
import 'package:dio/dio.dart';
import 'package:terra_flutter_bridge/terra_flutter_bridge.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'widgets/bluetooth_notfound_widget.dart';

class SetupDevicesScreen extends StatefulWidget {
  @override
  _SetupDevicesScreenState createState() => _SetupDevicesScreenState();
}

class _SetupDevicesScreenState extends State<SetupDevicesScreen> {

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
        child: Container(
          // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                bottom: 5.0,
              ),
              child: Text(
                'Devices Selection',
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
              padding: const EdgeInsets.only(
                bottom: 5.0,
              ),
              child: Text(
                'Device Details',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppTheme.title,
              ),
            ),
            Expanded(
              child: _buildDevicesList(context),
            )
          ]),
        ),
        // bottomNavigationBar: SafeArea(
        //   bottom: true,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       Container(
        //         width: 200,
        //         height: 90,
        //         padding: EdgeInsets.all(20),
        //         child: RaisedButton(
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(4.5),
        //           ),
        //           color: Theme.of(context).primaryColor,
        //           textColor: Colors.white,
        //           child: Text('Access Health Data'),
        //           onPressed: () {
        //             // return Navigator.of(context).pushReplacementNamed(
        //             //   routes.LoginRoute,
        //             // );

        //             return Navigator.of(context).push(
        //               MaterialPageRoute<Null>(
        //                 builder: (BuildContext context) {
        //                   return LoginScreen();
        //                 },
        //                 fullscreenDialog: true,
        //               ),
        //             );
        //           },
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  Widget _buildDevicesList(context) {
    return FutureBuilder(
      future: Provider.of<DevicesProvider>(context, listen: false)
          .fetchAllDevices(),
      builder: (ctx, hardwareDataSnapshot) {
        if (hardwareDataSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (hardwareDataSnapshot.error != null) {
            return Center(
              child: Text('An error occurred!'),
            );
          } else {
            if (hardwareDataSnapshot.data != null) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                ),
                itemCount: hardwareDataSnapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  if(hardwareDataSnapshot.data[index] is DevicesModel) {

                    var imageData = hardwareDataSnapshot
                        .data[index].deviceMaster['displayImage'];

                    var deviceName = hardwareDataSnapshot
                        .data[index].deviceMaster['name']
                        .toUpperCase();

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: InkWell(
                        onTap: () => {
                          if (deviceName == 'B500')
                            {
                              Navigator.of(context).pushNamed(
                                routes.SetupScaleOptionsRoute,
                                arguments: {
                                  'tag': 'imageHero' + index.toString(),
                                  'deviceData': hardwareDataSnapshot.data[index],
                                  'deviceType': deviceName,
                                  'displayImage': imageData,
                                },
                              )
                            }
                          else
                            {
                              Navigator.of(context).pushNamed(
                                routes.SetupConnectRoute,
                                arguments: {
                                  'tag': 'imageHero' + index.toString(),
                                  'deviceData': hardwareDataSnapshot.data[index],
                                  'deviceType': deviceName,
                                  'displayImage': imageData,
                                },
                              )
                            }
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: GridTile(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Hero(
                                    transitionOnUserGestures: true,
                                    tag: 'imageHero' + index.toString(),
                                    child: CachedNetworkImage(
                                      imageUrl: imageData,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      fadeInDuration: Duration(milliseconds: 200),
                                      fadeInCurve: Curves.easeIn,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              'assets/images/placeholder.jpg'),
                                    ),
                                  ),
                                ),
                                Container(
                                  // color: Colors.black.withOpacity(0.7),
                                  height: 30,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      hardwareDataSnapshot.data[index]
                                          .deviceMaster['displayName'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        // color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Regular',
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  else{
                    var imageData = hardwareDataSnapshot.data[index].imageUrl;

                    var deviceName = hardwareDataSnapshot.data[index].deviceName;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: InkWell(
                        onTap:  () async{
                          if (deviceName == 'Terra Devices')
                           {
                              Dio dio = new Dio();
                              dio.post(
                                  'https://api.tryterra.co/v2/auth/generateWidgetSession',
                                  data: {
                                    'reference_id': '1234',//please enter userID from your server.
                                    'providers': 'samsung, GARMIN, FITBIT, OURA, APPLE, COROS, CONCEPT2, CRONOMETER, Dexcom, Eight, Fatsecret,Freestylelibre,Google, Huawei,Ifit,Nutracheck,Omron,Peloton,Polar,Renpho,Suunto,Tempo,Trainingpeaks,Underarmour,Wahoo,WHOOP,Withings,Zwift',
                                    'auth_success_redirect_url': 'https://happy-developer.com',//please enter your server URL
                                    'auth_failure_redirect_url': 'https://sad-developer.com',//please enter your server URL
                                    'language': 'EN'
                                  },
                                  options: Options(
                                    headers: {
                                      'X-API-Key': 'a3e614f4481dbb92cca6d2957bde3f71951551e726710c2f7b88d7c7c5174562',
                                      'dev-id': 'ceras-dev-y5kN5MDRKv'
                                    }
                                  )
                              ).then((response) {
                                  print(response);
                                  Navigator.of(context).pushNamed(
                                    routes.SetupWebviewdRoute,
                                    arguments: {
                                    'title': "Add Terra Device",
                                    'selectedUrl': response.data['url']
                                    },
                                  );
                              });


                            }
                          else if(deviceName == 'SAMSUNG') {

                            bool initialised = false;
                            bool connected = false;
                            bool daily = false;
                            String testText;
                            Connection c = Connection.samsung;
                            try {
                              DateTime now = DateTime.now().toUtc();
                              DateTime lastMidnight = DateTime(now.year, now.month, now.day);

                              initialised = await TerraFlutter.initTerra("ceras-dev-y5kN5MDRKv", "test-User") ?? false;

                              connected = await TerraFlutter.initConnection(c, "UserToken comes from back end", false, []) ?? false;

                              // testText = await TerraFlutter.getUserId(c) ?? "1234";
                              if(connected) {
                                Navigator.of(context).pushNamed(
                                  routes.SetupConnectedRoute,
                                  arguments: {
                                    'deviceData': null,
                                    'displayImage': imageData,
                                  },
                                );
                              } else {
                                Navigator.of(context).pushNamed(
                                    routes.UnabletoconnectRoute
                                );
                              }

                            } on Exception catch (e) {
                              print('error caught: $e');
                              Navigator.of(context).pushNamed(
                                  routes.UnabletoconnectRoute
                              );
                            }

                          }
                          else if( deviceName == 'FREESTYLE_LIBRE') {
                            bool initialised = false;
                            bool connected = false;
                            bool daily = false;
                            String testText;
                            Connection c = Connection.freestyleLibre;
                            try {
                              DateTime now = DateTime.now().toUtc();
                              DateTime lastMidnight = DateTime(now.year, now.month, now.day);

                              initialised = await TerraFlutter.initTerra("ceras-dev-y5kN5MDRKv", "test-User") ?? false;

                              connected = await TerraFlutter.initConnection(c, "UserToken comes from back end", false, []) ?? false;

                              // testText = await TerraFlutter.getUserId(c) ?? "1234";
                              if(connected) {
                                Navigator.of(context).pushNamed(
                                  routes.SetupConnectedRoute,
                                  arguments: {
                                    'deviceData': null,
                                    'displayImage': imageData,
                                  },
                                );
                              } else {
                                Navigator.of(context).pushNamed(
                                    routes.UnabletoconnectRoute
                                );
                              }
                            } on Exception catch (e) {
                              print('error caught: $e');
                              Navigator.of(context).pushNamed(
                                  routes.UnabletoconnectRoute
                              );
                            }
                          } else if( deviceName == 'GOOGLE_FIT') {
                            bool initialised = false;
                            bool connected = false;
                            bool daily = false;
                            String testText;
                            Connection c = Connection.googleFit;
                            try {
                              DateTime now = DateTime.now().toUtc();
                              DateTime lastMidnight = DateTime(now.year, now.month, now.day);

                              initialised = await TerraFlutter.initTerra("ceras-dev-y5kN5MDRKv", "test-User") ?? false;

                              connected = await TerraFlutter.initConnection(c, "UserToken comes from back end", false, []) ?? false;

                              // testText = await TerraFlutter.getUserId(c) ?? "1234";
                              if(connected) {
                                Navigator.of(context).pushNamed(
                                  routes.SetupConnectedRoute,
                                  arguments: {
                                    'deviceData': null,
                                    'displayImage': imageData,
                                  },
                                );
                              } else {
                                Navigator.of(context).pushNamed(
                                    routes.UnabletoconnectRoute
                                );
                              }

                            } on Exception catch (e) {
                              print('error caught: $e');
                              Navigator.of(context).pushNamed(
                                  routes.UnabletoconnectRoute
                              );
                            }
                          }else if( deviceName == 'APPLE_HEALTH') {
                            bool initialised = false;
                            bool connected = false;
                            bool daily = false;
                            String testText;
                            Connection c = Connection.appleHealth;
                            try {
                              DateTime now = DateTime.now().toUtc();
                              DateTime lastMidnight = DateTime(now.year, now.month, now.day);

                              initialised = await TerraFlutter.initTerra("ceras-dev-y5kN5MDRKv", "test-User") ?? false;

                              connected = await TerraFlutter.initConnection(c, "UserToken comes from back end", false, []) ?? false;

                              // testText = await TerraFlutter.getUserId(c) ?? "1234";
                              if(connected) {
                                Navigator.of(context).pushNamed(
                                  routes.SetupConnectedRoute,
                                  arguments: {
                                    'deviceData': null,
                                    'displayImage': imageData,
                                  },
                                );
                              } else {
                                Navigator.of(context).pushNamed(
                                    routes.UnabletoconnectRoute
                                );
                              }

                            } on Exception catch (e) {
                              print('error caught: $e');
                              Navigator.of(context).pushNamed(
                                  routes.UnabletoconnectRoute
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: GridTile(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Hero(
                                    transitionOnUserGestures: true,
                                    tag: 'imageHero' + index.toString(),
                                    child: CachedNetworkImage(
                                      imageUrl: imageData,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center,
                                      fadeInDuration: Duration(milliseconds: 200),
                                      fadeInCurve: Curves.easeIn,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              'assets/images/placeholder.jpg'),
                                    ),
                                  ),
                                ),
                                Container(
                                  // color: Colors.black.withOpacity(0.7),
                                  height: 30,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      deviceName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        // color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Regular',
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                  }

                },
              );
            } else {
              return NoDataFoundWidget();
            }
          }
        }
      },
    );
  }
}

// Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               // Container(
//               //   padding: const EdgeInsets.all(10.0),
//               //   child: Text(
//               //     'Select Device',
//               //     overflow: TextOverflow.ellipsis,
//               //     textAlign: TextAlign.center,
//               //     style: AppTheme.title,
//               //   ),
//               // ),
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   child: Card(
//                     margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     child: InkWell(
//                       child: Container(
//                         padding: EdgeInsets.all(15),
//                         child: FadeInImage(
//                           placeholder: AssetImage(
//                             'assets/images/placeholder.jpg',
//                           ),
//                           image: AssetImage(
//                             'assets/images/Picture1.jpg',
//                           ),
//                           fit: BoxFit.contain,
//                           alignment: Alignment.center,
//                           fadeInDuration: Duration(milliseconds: 200),
//                           fadeInCurve: Curves.easeIn,
//                           height: 100,
//                           width: 200,
//                         ),
//                       ),
//                       onTap: () => {
//                         Navigator.of(context).pushNamed(
//                           routes.SetupConnectRoute,
//                           arguments: {
//                             'deviceType': 'WATCH',
//                           },
//                         ),
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   child: Card(
//                     margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     child: InkWell(
//                       child: Container(
//                         padding: EdgeInsets.all(15),
//                         child: FadeInImage(
//                           placeholder: AssetImage(
//                             'assets/images/placeholder.jpg',
//                           ),
//                           image: AssetImage(
//                             'assets/images/Picture2.jpg',
//                           ),
//                           fit: BoxFit.contain,
//                           alignment: Alignment.center,
//                           fadeInDuration: Duration(milliseconds: 200),
//                           fadeInCurve: Curves.easeIn,
//                           height: 100,
//                           width: 200,
//                         ),
//                       ),
//                       onTap: () => {
//                         Navigator.of(context).pushNamed(
//                           routes.SetupConnectRoute,
//                           arguments: {
//                             'deviceType': 'BAND',
//                           },
//                         ),
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//  GridView.count(
//               shrinkWrap: true,
//               crossAxisCount: 1,
//               padding: EdgeInsets.all(5.0),
//               childAspectRatio: 1.0 / 1.0,
//               children: [
//                 Card(
//                   margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: InkWell(
//                     child: Container(
//                       padding: EdgeInsets.all(15),
//                       child: GridTile(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Expanded(
//                               child: FadeInImage(
//                                 placeholder: AssetImage(
//                                   'assets/images/placeholder.jpg',
//                                 ),
//                                 image: AssetImage(
//                                   'assets/images/Picture1.jpg',
//                                 ),
//                                 fit: BoxFit.contain,
//                                 alignment: Alignment.center,
//                                 fadeInDuration: Duration(milliseconds: 200),
//                                 fadeInCurve: Curves.easeIn,
//                                 height: 100,
//                                 width: 200,
//                               ),
//                             ),
//                           ],
//                         ),
//                         // footer: Center(
//                         //   child: Text(
//                         //     'Connect',
//                         //     overflow: TextOverflow.ellipsis,
//                         //     textAlign: TextAlign.center,
//                         //     style: TextStyle(
//                         //       fontSize: 16,
//                         //       fontWeight: FontWeight.w500,
//                         //     ),
//                         //   ),
//                         // ),
//                       ),
//                     ),
//                     onTap: () => {
//                       Navigator.of(context).pushNamed(
//                         routes.SetupConnectRoute,
//                         arguments: {
//                           'deviceType': 'WATCH',
//                         },
//                       ),
//                     },
//                   ),
//                 ),
//                 Card(
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                   child: InkWell(
//                     child: Container(
//                       padding: EdgeInsets.all(15),
//                       child: GridTile(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Expanded(
//                               child: FadeInImage(
//                                 placeholder: AssetImage(
//                                   'assets/images/placeholder.jpg',
//                                 ),
//                                 image: AssetImage(
//                                   'assets/images/Picture2.jpg',
//                                 ),
//                                 fit: BoxFit.contain,
//                                 alignment: Alignment.center,
//                                 fadeInDuration: Duration(milliseconds: 200),
//                                 fadeInCurve: Curves.easeIn,
//                                 height: 100,
//                                 width: 200,
//                               ),
//                             ),
//                           ],
//                         ),
//                         // footer: Center(
//                         //   child: Text(
//                         //     'Connect',
//                         //     overflow: TextOverflow.ellipsis,
//                         //     textAlign: TextAlign.center,
//                         //     style: TextStyle(
//                         //       fontSize: 16,
//                         //       fontWeight: FontWeight.w500,
//                         //     ),
//                         //   ),
//                         // ),
//                       ),
//                     ),
//                     onTap: () => {
//                       Navigator.of(context).pushNamed(
//                         routes.SetupConnectRoute,
//                         arguments: {
//                           'deviceType': 'BAND',
//                         },
//                       ),
//                     },
//                   ),
//                 ),
//               ],
//             ),
