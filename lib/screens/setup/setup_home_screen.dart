import 'package:flutter/material.dart';
import 'package:lifeplus/theme.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;

class SetupHomeScreen extends StatelessWidget {
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
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Select Device',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTheme.title,
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              padding: EdgeInsets.all(10.0),
              childAspectRatio: 1.0 / 1.0,
              children: [
                Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: GridTile(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FadeInImage(
                                placeholder: AssetImage(
                                  'assets/images/placeholder.jpg',
                                ),
                                image: AssetImage(
                                  'assets/images/Picture1.png',
                                ),
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                fadeInDuration: Duration(milliseconds: 200),
                                fadeInCurve: Curves.easeIn,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                        footer: Center(
                          child: Text(
                            'Connect',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () => {
                      Navigator.of(context).pushNamed(
                        routes.BluetoothNotfoundRoute,
                      ),
                    },
                  ),
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: GridTile(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FadeInImage(
                                placeholder: AssetImage(
                                  'assets/images/placeholder.jpg',
                                ),
                                image: AssetImage(
                                  'assets/images/Picture2.png',
                                ),
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                fadeInDuration: Duration(milliseconds: 200),
                                fadeInCurve: Curves.easeIn,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                        footer: Center(
                          child: Text(
                            'Connect',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () => {
                      Navigator.of(context).pushNamed(
                        routes.SetupConnectRoute,
                      ),
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
