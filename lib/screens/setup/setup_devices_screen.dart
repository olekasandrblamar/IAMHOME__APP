import 'package:cached_network_image/cached_network_image.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/screens/auth/login_screen.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/nodata_widget.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  var imageData = hardwareDataSnapshot
                      .data[index].deviceMaster['displayImage'];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      onTap: () => {
                        Navigator.of(context).pushNamed(
                          routes.SetupConnectRoute,
                          arguments: {
                            'tag': 'imageHero' + index.toString(),
                            'deviceData': hardwareDataSnapshot.data[index],
                            'deviceType': hardwareDataSnapshot
                                .data[index].deviceMaster['name']
                                .toUpperCase(),
                            'displayImage': imageData,
                          },
                        ),
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
