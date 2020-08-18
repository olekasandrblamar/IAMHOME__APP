import 'package:ceras/config/user_deviceinfo.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:ceras/config/app_localizations.dart';
import 'package:ceras/widgets/apppermissions_widget.dart';
import 'package:ceras/widgets/languageselection_widget.dart';

import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/theme.dart';
import 'package:package_info/package_info.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationVersion: _packageInfo.version,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _appLocalization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appLocalization.translate('settings.title'),
        ),
      ),
      // drawer: HardwareAppDrawer(routes.SettingsRoute),
      backgroundColor: AppTheme.background,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          padding: EdgeInsets.all(10.0),
          childAspectRatio: 1.0 / 1.0,
          children: [
            Card(
              child: Container(
                padding: EdgeInsets.all(15),
                child: GridTile(
                  child: new InkResponse(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Icon(
                            Icons.language,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Container(
                          height: 10,
                        ),
                      ],
                    ),
                    onTap: () => {
                      Navigator.of(context).push(
                        MaterialPageRoute<Null>(
                          builder: (BuildContext context) {
                            return LanguageSelection();
                          },
                          fullscreenDialog: true,
                        ),
                      )
                    },
                  ),
                  footer: Center(
                    child: Text(
                      // _appLocalization.translate('settings.content.language'),
                      'Language',
                    ),
                  ),
                ),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(15),
                child: GridTile(
                  child: InkResponse(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Icon(
                            Icons.build,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Container(
                          height: 10,
                        ),
                      ],
                    ),
                    onTap: () => {
                      Navigator.of(context).push(
                        MaterialPageRoute<Null>(
                          builder: (BuildContext context) {
                            return AppPermissions();
                          },
                          fullscreenDialog: true,
                        ),
                      )
                    },
                  ),
                  footer: Container(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        _appLocalization
                            .translate('settings.content.permissions'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Card(
            //   child: Container(
            //     padding: EdgeInsets.all(15),
            //     child: GridTile(
            //       child: new InkResponse(
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Expanded(
            //               child: Icon(
            //                 Icons.rate_review,
            //                 size: 50,
            //                 color: Theme.of(context).primaryColor,
            //               ),
            //             ),
            //             Container(
            //               height: 10,
            //             ),
            //           ],
            //         ),
            //         onTap: () => {
            //           LaunchReview.launch(
            //             // writeReview: false,
            //             androidAppId: "com.cerashealth.ceras",
            //             // iOSAppId: "1493080545",
            //           )
            //         },
            //       ),
            //       footer: Container(
            //         padding: EdgeInsets.only(top: 50),
            //         child: Center(
            //           child: Text(
            //             _appLocalization.translate('settings.content.review'),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: InkWell(
          child: Container(
            width: double.infinity,
            // alignment: Alignment.center,
            child: ListTile(
              title: Text(
                _appLocalization.translate('settings.appversion'),
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                _packageInfo.version + '+' + _packageInfo.buildNumber,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          onTap: () => _showAboutDialog(),
        ),
      ),
    );
  }
}
