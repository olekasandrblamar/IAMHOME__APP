import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/screens/auth/login_screen.dart';
import 'package:ceras/theme.dart';
import 'package:ceras/widgets/setup_appbar_widget.dart';
import 'package:flutter/material.dart';

class SetupHomeScreen extends StatefulWidget {
  @override
  _SetupHomeScreenState createState() => _SetupHomeScreenState();
}

class _SetupHomeScreenState extends State<SetupHomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SetupAppBar(name: 'My Devices'),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  margin: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: 150,
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            child: Image.asset(
                              'assets/images/AddNewDeviceDefault.png',
                              height: 75,
                              width: 75,
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              'Add New Device',
                              style: AppTheme.title,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => {
                      Navigator.of(context).pushNamed(
                        routes.SetupDevicesRoute,
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                child: Text('Access Health Data'),
                onPressed: () {
                  // return Navigator.of(context).pushReplacementNamed(
                  //   routes.LoginRoute,
                  // );

                  return Navigator.of(context).push(
                    MaterialPageRoute<Null>(
                      builder: (BuildContext context) {
                        return LoginScreen();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
