import 'dart:async';
import 'dart:convert';
import 'package:ceras/models/devices_model.dart';
import 'package:ceras/screens/setup/setup_connected_screen.dart';
import 'package:ceras/screens/setup/setup_home_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:ceras/theme.dart';

import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:ceras/config/background_fetch.dart';
import 'package:flutter/services.dart';
import 'package:ceras/models/watchdata_model.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_settings/system_settings.dart';

class ConnectionWifiScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  ConnectionWifiScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _ConnectionWifiScreenState createState() => _ConnectionWifiScreenState();
}

class _ConnectionWifiScreenState extends State<ConnectionWifiScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  DevicesModel _devicesModel;
  var _displayImage = '';

  String _connectionStatus = 'Unknown';
  String _wifiName, _password = '';
  bool _showPassword = true;
  bool _initialSetup = false;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // final TextEditingController _wifiController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _wifiFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    if (_isInit) {
      // _usernameController.text = null;
      // _wifiController = null;
      _passwordController.text = null;
    }

    DevicesModel deviceModel;
    String displayImage;
    var initialSetup = true;

    if (widget.routeArgs != null) {
      deviceModel = widget.routeArgs['deviceData'];
      displayImage = widget.routeArgs['displayImage'];
      if (widget.routeArgs['initialSetup'] != null) {
        initialSetup = widget.routeArgs['initialSetup'];
      }
    }
    setState(() {
      _devicesModel = deviceModel;
      _initialSetup = initialSetup;
      _displayImage = displayImage;
    });

    initConnectivity();
    loadData();

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);

    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

    // _wifiController.dispose();
    _passwordController.dispose();

    // _usernameFocusNode.dispose();
    _wifiFocusNode.dispose();
    _passwordFocusNode.dispose();

    _connectivitySubscription.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        loadData();
        break;
      case AppLifecycleState.inactive:
        loadData();
        break;
      case AppLifecycleState.paused:
        loadData();
        break;
      case AppLifecycleState.detached:
        loadData();
        break;
    }
  }

  void loadData() async {
    var wifiName = await (NetworkInfo().getWifiName());
    print(wifiName);

    if (wifiName != null) {
      setState(() {
        _wifiName = wifiName;
        // _wifiController = wifiName;
      });
    }

    setState(() {
      _isInit = false;
    });
    // showWrongPasswordDialog(context);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    var result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        setState(() => _connectionStatus = 'wifi');
        break;
      case ConnectivityResult.mobile:
        setState(() => _connectionStatus = 'mobile');
        break;
      case ConnectivityResult.none:
        setState(() => _connectionStatus = 'no');
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  Future<void> _connectWifi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isValid = _formKey.currentState.validate();
      if (!isValid) {
        return;
      }
      // setState(() {
      //   _isLoading = true;
      // });
      _formKey.currentState.save();

      final connectionInfo = prefs.getString('watchInfo');

      _loadingDialog();
      final connectionStatus = await BackgroundFetchData.platform.invokeMethod(
        'connectWifi',
        <String, dynamic>{
          'connectionInfo': connectionInfo,
          'network': _wifiName,
          'password': _password
        },
      ) as String;

      print('Wifi status $connectionStatus');

      final wifiStatus = WatchModel.fromJson(
        json.decode(connectionStatus) as Map<String, dynamic>,
      );
      //Hide the loading screen
      Navigator.of(context).pop();

      if (wifiStatus.connected) {
        sendToSuccessScreen(true);
      } else {
        showErrorDialog(context, wifiStatus.message);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);

      showErrorDialog(context, error.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  void sendToSuccessScreen(bool connectivityStatus) async {
    _devicesModel.wifiConnected = connectivityStatus;
    if (_initialSetup) {
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => SetupConnectedScreen(
              routeArgs: {
                'deviceData': _devicesModel,
                'displayImage': _displayImage,
              },
            ),
            settings: const RouteSettings(name: routes.SetupConnectedRoute),
          ),
          (Route<dynamic> route) => false);
    } else {
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => SetupHomeScreen(),
            settings: const RouteSettings(name: routes.SetupHomeRoute),
          ),
          (Route<dynamic> route) => false);
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    if (message == 'Invalid Password') {
      showWrongPasswordDialog(context);
    }else{
      showWifiFailure(context);
    }
    // showDialog(
    //   context: context,
    //   builder: (ctx) => AlertDialog(
    //     title: Text('An Error Occurred!'),
    //     content: Text(
    //       message ?? 'Could not authenticate you. Please try again later.',
    //     ),
    //     actions: <Widget>[
    //       FlatButton(
    //         child: Text('Okay'),
    //         onPressed: () {
    //           Navigator.of(ctx).pop();
    //         },
    //       )
    //     ],
    //   ),
    // );
  }

  void _loadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SimpleDialog(
        // title: Text(
        //   'Title',
        //   textAlign: TextAlign.center,
        // ),
        // backgroundColor: Colors.blueAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        children: <Widget>[
          Center(child: CircularProgressIndicator()),
          SizedBox(
            height: 16,
          ),
          Text(
            'Connecting to wifi',
            textAlign: TextAlign.center,
            style: AppTheme.subtitle,
          ),
        ],
      ),
    );
  }

  void showWifiFailure(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Can't find network"),
        content: Text(
          'Unable to find the wireless network to connect. Can you try again !',
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Retry'),
                ),
                SizedBox(width: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    //Send to Done screen
                    sendToSuccessScreen(false);
                  },
                  child: Text('Continue'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void showWrongPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Wrong Password'),
        content: Text(
          'The network and password combinations entered are incorrect. Can you retry one more time again!',
        ),
        actions: <Widget>[
          Container(
            // padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Retry'),
                ),
                SizedBox(width: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    sendToSuccessScreen(false);
                  },
                  child: Text('Continue'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 5.0),
            !_isInit
                ? _connectionStatus != 'wifi'
                    ? NoWifiConnectionWidget(context)
                    : _wifiName != null
                        ? EnterWifiInformation(context)
                        : NoLocationEnabledWidget(context)
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        ),
      ),
    );
  }

  Container EnterWifiInformation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            // TextFormField(
            //     style: TextStyle(
            //       fontSize: 24,
            //     ),
            //     decoration: _inputDecoration('Wifi Name', 'Wifi Name'),
            //     controller: _wifiController,
            //     enabled: false,
            //     keyboardType: TextInputType.text,
            //     textInputAction: TextInputAction.next,
            //     autofocus: false,
            //     validator: (String value) {
            //       if (value.isEmpty) {
            //         return 'Please Enter Wifi Name.';
            //       }

            //       return null;
            //     }
            //     // onChanged: onChangePhoneNumberInput,
            //     ),
            GestureDetector(
              onTap: () {
                SystemSettings.wifi();
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi),
                    FittedBox(
                      child: Text(
                        _wifiName ?? 'WIFI Name',
                        style: AppTheme.title,
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
                style: TextStyle(
                  fontSize: 24,
                ),
                // suffixIcon: Icon(Icons.remove_red_eye),
                decoration: _inputDecoration('Password', ''),
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                obscureText: _showPassword,
                autofocus: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter password.';
                  }

                  if (value.length < 3) {
                    return 'password must be more than 2 charater';
                  }

                  return null;
                },
                onSaved: (password) => _password = password),
            SizedBox(
              height: 50,
            ),
            _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      width: 180.0,
                      height: 60.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () => _connectWifi(),
                        child: Text(
                          'Submit',
                        ),
                      ),
                    ),
                  )
            // Container(
            //   width: 200,
            //   height: 75,
            //   padding: EdgeInsets.all(10),
            //   child: RaisedButton(
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(4.5),
            //     ),
            //     // color: Theme.of(context).primaryColor,
            //     // textColor: Colors.white,
            //     onPressed: () async {
            //       return Navigator.of(context).pushReplacementNamed(
            //         routes.SetupHomeRoute,
            //       );
            //     },
            //     child: Text(
            //       'Skip',
            //       style: TextStyle(
            //         fontSize: 14,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Container NoLocationEnabledWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              maxHeight: 300.0,
            ),
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'assets/images/noConnection.png',
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'No Location Enabled',
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
              'Please turn on your location and comeback',
              textAlign: TextAlign.center,
              style: AppTheme.subtitle,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            width: 200,
            height: 75,
            padding: EdgeInsets.all(10),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.5),
              ),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () async {
                await openAppSettings();
              },
              child: Text(
                'Open Settings',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            width: 200,
            height: 75,
            padding: EdgeInsets.all(10),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.5),
              ),
              // color: Theme.of(context).primaryColor,
              // textColor: Colors.white,
              onPressed: () async {
                return Navigator.of(context).pushReplacementNamed(
                  routes.SetupHomeRoute,
                );
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container NoWifiConnectionWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              maxHeight: 300.0,
            ),
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'assets/images/noConnection.png',
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'No Wifi Connection Detected',
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
              'Please turn on your wifi and comeback',
              textAlign: TextAlign.center,
              style: AppTheme.subtitle,
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            width: 200,
            height: 75,
            padding: EdgeInsets.all(10),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.5),
              ),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: () async {
                return Navigator.of(context).pushReplacementNamed(
                  routes.SetupHomeRoute,
                );
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(labelText, hintText) {
    return InputDecoration(
      contentPadding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 30,
        bottom: 0,
      ),
      filled: true,
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: Colors.grey),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: Colors.red),
      ),
      suffixIcon: (labelText == 'Password')
          ? IconButton(
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              icon: _showPassword
                  ? Icon(Icons.visibility_off)
                  : Icon(Icons.visibility),
            )
          : Container(
              height: 0,
              width: 0,
            ),
    );
  }
}
