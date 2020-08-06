import 'package:flutter/material.dart';
import 'package:ceras/theme.dart';

import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/widgets/apppermissions_widget.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Container(
              //   padding: const EdgeInsets.all(10.0),
              //   child: Text(
              //     'Select Device',
              //     overflow: TextOverflow.ellipsis,
              //     textAlign: TextAlign.center,
              //     style: AppTheme.title,
              //   ),
              // ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: FadeInImage(
                          placeholder: AssetImage(
                            'assets/images/placeholder.jpg',
                          ),
                          image: AssetImage(
                            'assets/images/Picture1.jpg',
                          ),
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          fadeInDuration: Duration(milliseconds: 200),
                          fadeInCurve: Curves.easeIn,
                          height: 100,
                          width: 200,
                        ),
                      ),
                      onTap: () => {
                        Navigator.of(context).pushNamed(
                          routes.SetupConnectRoute,
                          arguments: {
                            'deviceType': 'WATCH',
                          },
                        ),
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: FadeInImage(
                          placeholder: AssetImage(
                            'assets/images/placeholder.jpg',
                          ),
                          image: AssetImage(
                            'assets/images/Picture2.jpg',
                          ),
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          fadeInDuration: Duration(milliseconds: 200),
                          fadeInCurve: Curves.easeIn,
                          height: 100,
                          width: 200,
                        ),
                      ),
                      onTap: () => {
                        Navigator.of(context).pushNamed(
                          routes.SetupConnectRoute,
                          arguments: {
                            'deviceType': 'BAND',
                          },
                        ),
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
