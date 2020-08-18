import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/providers/devices_provider.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/nodata_widget.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SetupAppBar(),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: true,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: FutureBuilder(
            future: Provider.of<DevicesProvider>(context, listen: false)
                .fetchAllDevices(),
            builder: (ctx, hardwareDataSnapshot) {
              if (hardwareDataSnapshot.connectionState ==
                  ConnectionState.waiting) {
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
                        crossAxisCount: 2,
                      ),
                      itemCount: hardwareDataSnapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        var imageData = hardwareDataSnapshot
                            .data[index].deviceMaster['displayImage'];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: InkWell(
                            child: Container(
                              padding: EdgeInsets.all(5),
                              child: GridTile(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: FadeInImage(
                                        placeholder: AssetImage(
                                          'assets/images/placeholder.jpg',
                                        ),
                                        image: imageData != null
                                            ? NetworkImage(
                                                imageData,
                                              )
                                            : AssetImage(
                                                'assets/images/placeholder.jpg',
                                              ),
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        fadeInDuration:
                                            Duration(milliseconds: 200),
                                        fadeInCurve: Curves.easeIn,
                                        width: double.infinity,
                                        height: double.infinity,
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
                            onTap: () => {
                              Navigator.of(context).pushNamed(
                                routes.SetupConnectRoute,
                                arguments: {
                                  'deviceType': hardwareDataSnapshot.data[index]
                                          .deviceMaster['deviceType']
                                      ['displayName'],
                                  'displayImage': imageData,
                                },
                              ),
                            },
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
          ),
        ),
      ),
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
