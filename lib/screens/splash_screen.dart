import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   Timer _timer;

//   FlutterLogoStyle _logoStyle = FlutterLogoStyle.markOnly;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     _timer = new Timer(const Duration(seconds: 2), () {
//       setState(() {
//         _logoStyle = FlutterLogoStyle.horizontal;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();

//     _timer.cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Container(
//             child: new FlutterLogo(
//               size: 200.0,
//               style: _logoStyle,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
