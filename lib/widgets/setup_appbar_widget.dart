import 'package:flutter/material.dart';
import 'package:lifeplus/screens/help/help_widget.dart';
import 'package:lifeplus/widgets/apppermissions_widget.dart';

import 'package:lifeplus/constants/route_paths.dart' as routes;

class SetupAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SetupAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0.0,
      title: Row(children: [
        IconButton(
          // color: Colors.black,
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<Null>(
                builder: (BuildContext context) {
                  return AppPermissions();
                },
                fullscreenDialog: true,
              ),
            );
          },
        ),
        Expanded(
          child: Center(
              child: Text(
            'Select Device',
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
