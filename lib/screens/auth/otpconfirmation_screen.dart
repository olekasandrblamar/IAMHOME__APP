import 'dart:async';

import 'package:ceras/providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:ceras/constants/route_paths.dart' as routes;

class OtpConfirmationScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  OtpConfirmationScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _OtpConfirmationScreenState createState() => _OtpConfirmationScreenState();
}

class _OtpConfirmationScreenState extends State<OtpConfirmationScreen> {
  var onTapRecognizer;

  TextEditingController pinCodeController = TextEditingController();

  StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  String currentText = '';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  String _email = '';
  String _otpToken = '';

  @override
  void initState() {
    if (widget.routeArgs != null) {
      _email = widget.routeArgs['email'];
      forgotPassword();
    }

    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        // Navigator.pop(context);
        forgotPassword();
      };
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController.close();

    super.dispose();
  }

  Future<void> forgotPassword() async {
    try {
      var profileInfo = await Provider.of<AuthProvider>(context, listen: false)
          .forgotPassword(email: _email);

      _otpToken = profileInfo['otpToken'];
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> validateOtp() async {
    try {
      var validateOtpData =
          await Provider.of<AuthProvider>(context, listen: false)
              .validateOtp(otpCode: currentText, otpToken: _otpToken);

      // print(validateOtpData);

      if (validateOtpData != null) {
        if (validateOtpData['otpToken'] != null) {
          return Navigator.of(context).pushReplacementNamed(
            routes.PasswordExpiredRoute,
            arguments: {'token': validateOtpData['otpToken']},
          );
        } else {
          showErrorDialog(validateOtpData['return_string']);
        }
      } else {
        showErrorDialog(null);
      }
    } catch (ex) {
      print(ex);
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(
          message ?? 'Invalid. Please try again later.',
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(color: Colors.black),
        backgroundColor: Color(0xffecf3fb),
        elevation: 0,
        // actions: <Widget>[
        //   SwitchStoreIcon(),
        // ],
      ),
      backgroundColor: Color(0xffecf3fb),
      key: scaffoldKey,
      body: GestureDetector(
        onTap: () {},
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              _buildLoginTopHeader(),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Email Verification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: RichText(
                  text: TextSpan(
                      text: 'Enter the code sent to ',
                      children: [
                        TextSpan(
                            text: _email,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                      style: TextStyle(color: Colors.black54, fontSize: 15)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 30),
                    child: PinCodeTextField(
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obscureText: false,
                      obscuringCharacter: '*',
                      animationType: AnimationType.fade,
                      validator: (v) {
                        if (v.length < 3) {
                          return "I'm from validator";
                        } else {
                          return null;
                        }
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 60,
                        fieldWidth: 50,
                        activeFillColor:
                            hasError ? Colors.orange : Colors.white,
                      ),
                      cursorColor: Colors.black,
                      animationDuration: Duration(milliseconds: 300),
                      textStyle: TextStyle(fontSize: 20, height: 1.6),
                      backgroundColor: Color(0xffecf3fb),
                      enableActiveFill: true,
                      errorAnimationController: errorController,
                      controller: pinCodeController,
                      keyboardType: TextInputType.text,
                      boxShadows: [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.black12,
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) {
                        print('Completed');
                      },
                      // onTap: () {
                      //   print("Pressed");
                      // },
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          currentText = value;
                        });
                      },
                      beforeTextPaste: (text) {
                        print('Allowing to paste $text');
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  hasError ? '*Please fill up all the cells properly' : '',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Didn't receive the code? ",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  children: [
                    TextSpan(
                      text: 'RESEND',
                      recognizer: onTapRecognizer,
                      style: TextStyle(
                          color: Color(0xffc10b03),
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 14,
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                child: ButtonTheme(
                  height: 50,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.5),
                    ),
                    onPressed: () {
                      formKey.currentState.validate();
                      // conditions for validating
                      if (currentText.length != 6) {
                        errorController.add(
                          ErrorAnimationType.shake,
                        ); // Triggering error shake animation
                        setState(() {
                          hasError = true;
                        });
                      } else {
                        setState(() {
                          hasError = false;
                          validateOtp();
                        });
                      }
                    },
                    child: Center(
                        child: Text(
                      'VERIFY'.toUpperCase(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              ),
              // SizedBox(
              //   height: 16,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     FlatButton(
              //       child: Text("Clear"),
              //       onPressed: () {
              //         pinCodeController.clear();
              //       },
              //     ),
              //     FlatButton(
              //       child: Text("Set Text"),
              //       onPressed: () {
              //         pinCodeController.text = "123456";
              //       },
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTopHeader() {
    return Container(
      height: 200,
      child: Stack(
        children: <Widget>[
          // Container(
          //   alignment: Alignment.center,
          //   child: Image.asset(
          //     'assets/images/clouds.png',
          //     height: 250,
          //     width: double.infinity,
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Positioned(
            left: 10.0,
            top: 10.0,
            child: Container(
              alignment: Alignment.topLeft,
              width: 200,
              child: FittedBox(
                child: Text(
                  'Forgot',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 60.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10.0,
            top: 70.0,
            child: Container(
              alignment: Alignment.topLeft,
              width: 300,
              child: FittedBox(
                child: Text(
                  'Password,',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 60.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20.0,
            bottom: 10.0,
            child: Container(
              child: Image.asset(
                'assets/images/bee_right.png',
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
