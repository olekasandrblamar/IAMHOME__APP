import 'package:cached_network_image/cached_network_image.dart';
import 'package:ceras/screens/setup/setup_home_screen.dart';
import 'package:flutter/material.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

import '../../theme.dart';

class SetupConnectedScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  SetupConnectedScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _SetupConnectedScreenState createState() => _SetupConnectedScreenState();
}

class _SetupConnectedScreenState extends State<SetupConnectedScreen> {
  var _displayImage = '';

  @override
  void initState() {
    if (widget.routeArgs != null) {
      _displayImage = widget.routeArgs['displayImage'];
    }

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  bottom: 5.0,
                ),
                child: Text(
                  'Success',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
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
                child: Text(
                  'Device Connected!',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTheme.title,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                elevation: 5.0,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 250.0,
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: CachedNetworkImage(
                          imageUrl: _displayImage,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          fadeInDuration: Duration(milliseconds: 200),
                          fadeInCurve: Curves.easeIn,
                          errorWidget: (context, url, error) =>
                              Image.asset('assets/images/placeholder.jpg'),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 100.0,
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/images/Bluechecked.png',
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 90,
                        padding: EdgeInsets.all(20),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.5),
                          ),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          child: Text(
                            'Done',
                          ),
                          onPressed: () {
                            // return Navigator.of(context).pushReplacementNamed(
                            //   routes.SetupHomeRoute,
                            // );

                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      SetupHomeScreen(),
                                  settings: const RouteSettings(
                                      name: routes.SetupHomeRoute),
                                ),
                                (Route<dynamic> route) => false);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
