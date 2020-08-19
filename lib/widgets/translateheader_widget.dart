import 'package:flutter/material.dart';
import 'languageselection_widget.dart';

AppBar translateHeader(context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    // title: Text('Home'),
    actions: <Widget>[
      IconButton(
        color: Colors.black,
        icon: const Icon(Icons.translate),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return LanguageSelection();
              },
              fullscreenDialog: true,
            ),
          );
        },
      )
    ],
  );
}
