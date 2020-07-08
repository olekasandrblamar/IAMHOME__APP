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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Material(
              color: Colors.blue[100],
              child: InkWell(
                onTap: () {
                  return Navigator.of(context).pushNamed(
                    routes.SetupSearchRoute,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Image(
                        fit: BoxFit.contain,
                        image: AssetImage('assets/images/Picture1.png'),
                      ),
                      Text(
                        'CONNECT',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Material(
              color: Colors.blue[100],
              child: InkWell(
                onTap: () {
                  return Navigator.of(context).pushNamed(
                    routes.SetupSearchRoute,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Image(
                        fit: BoxFit.contain,
                        image: AssetImage('assets/images/Picture2.png'),
                      ),
                      Text(
                        'CONNECT',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text('Restart Demo'),
              onPressed: () {
                return Navigator.of(context).pushReplacementNamed(
                  routes.IntroRoute,
                );
              }),
        ),
      ),
    );
  }
}
