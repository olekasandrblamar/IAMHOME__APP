import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

import 'package:ceras/theme.dart';

class HelpScreen extends StatelessWidget {
  void _callUs() async {
    const url = 'tel:+18773001232';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Help',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        // actions: <Widget>[
        //   SwitchStoreIcon(),
        // ],
      ),
      backgroundColor: AppTheme.white,
      body: SafeArea(
        top: true,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                    'assets/images/support.png',
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
                  'Contact Support',
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
                  'To better connect with you, the care plan you select require us to send you the notifications. Join the wellness tracker program so Ceras can continue to update your activites.',
                  textAlign: TextAlign.center,
                  style: AppTheme.subtitle,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 150,
                    height: 75,
                    padding: EdgeInsets.all(10),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.5),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text(
                        'Call Us',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _callUs(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
