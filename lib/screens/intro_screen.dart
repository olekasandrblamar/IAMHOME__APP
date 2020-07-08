import 'package:flutter/material.dart';
import 'package:lifeplus/constants/route_paths.dart' as routes;
import 'package:lifeplus/theme.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Home'),
      // ),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                physics: BouncingScrollPhysics(),
                itemBuilder: (ctx, position) => Container(
                  padding: EdgeInsets.all(15),
                  child: Card(
                    elevation: 5,
                    color: Colors.white,
                    child: ListView(
                      children: <Widget>[
                        SizedBox(height: 5.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight: 200.0,
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: FadeInImage(
                                  placeholder: AssetImage(
                                    'assets/images/1.png',
                                  ),
                                  image: AssetImage(
                                    'assets/images/1.png',
                                  ),
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  fadeInDuration: Duration(milliseconds: 200),
                                  fadeInCurve: Curves.easeIn,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  'Health Monitored.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  // vertical: 5.0,
                                  horizontal: 10.0,
                                ),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Automatically record your wellness data from the device and send them to your doctor for review of your health. Just wear it and forget it',
                                  textAlign: TextAlign.left,
                                  style: AppTheme.subtitle,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text('Let\'s Go'),
              onPressed: () {
                return Navigator.of(context).pushReplacementNamed(
                  routes.PrivacyRoute,
                );
              }),
        ),
      ),
    );
  }
}
