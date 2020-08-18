import 'package:ceras/config/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:ceras/screens/help/help_widget.dart';
import 'package:ceras/widgets/apppermissions_widget.dart';

import 'package:ceras/constants/route_paths.dart' as routes;

class SetupAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SetupAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _appLocalization = AppLocalizations.of(context);
    return AppBar(
      titleSpacing: 0.0,
      title: Row(children: [
        IconButton(
          // color: Colors.black,
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.of(context).pushNamed(routes.SettingsRoute);
          },
        ),
        Expanded(
          child: Center(
              child: Text(
            _appLocalization.translate('setup.home.title'),
            // style: TextStyle(
            //   color: Colors.black,
            // ),
          )),
        )
      ]),
      actions: <Widget>[
        IconButton(
          // color: Colors.black,
          icon: const Icon(Icons.headset_mic),
          onPressed: () {
            // Navigator.of(context).pushNamed(
            //   routes.HelpRoute,
            // );

            Navigator.of(context).push(
              MaterialPageRoute<Null>(
                builder: (BuildContext context) {
                  return HelpScreen();
                },
                fullscreenDialog: true,
              ),
            );
          },
        )
      ],
      // backgroundColor: Colors.white,
      // elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
