import 'package:ceras/models/profile_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ceras/constants/route_paths.dart' as routes;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';

  final TextEditingController _emailController = TextEditingController();

  var _isInit = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _loadInitData();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) {
      return;
    }

    var userId = await Provider.of<AuthProvider>(context, listen: false).userId;

    if (userId != null) {
      setState(() {
        _emailController.text = userId;
      });
    } else {
      var profileInfo =
          await Provider.of<DevicesProvider>(context, listen: false)
              .getProfileInfo();

      if (profileInfo != null && profileInfo?.email != null) {
        setState(() {
          _emailController.text = profileInfo?.email;
        });
      }
    }
  }

  void _loadInitData() async {
    if (_isInit) {
      _emailController.text = null;
    }

    await _loadUserData();
    _isInit = false;
  }

  void fieldFocusChange(
    BuildContext context,
    FocusNode currentFocus,
    FocusNode nextFocus,
  ) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(
          message ?? 'Could not authenticate you. Please try again later.',
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

  Future<void> _saveForm() async {
    try {
      final isValid = _formKey.currentState.validate();
      if (!isValid) {
        return;
      }
      _formKey.currentState.save();

      return Navigator.of(context).pushReplacementNamed(
        routes.OtpConfirmationRoute,
        arguments: {
          'email': _emailController.text,
        },
      );
    } catch (error) {
      print(error);
      showErrorDialog(context, error.toString());
    }
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
      body: SafeArea(
        bottom: true,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLoginTopHeader(),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _emailInput(),
                        const SizedBox(height: 40),
                        _submitButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _emailInput() {
    return TextFormField(
      style: TextStyle(
        fontSize: 24,
      ),
      decoration: _inputDecoration('Email', 'e.g abc@gmail.com'),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofocus: false,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter email.';
        }

        final isValid = EmailValidator.validate(value);
        if (!isValid) {
          return 'Invalid email address';
        }

        return null;
      },
      onFieldSubmitted: (_) {},
      onSaved: (email) => _email = email,
      // onChanged: onChangePhoneNumberInput,
    );
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: 220.0,
        height: 60.0,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: () => _saveForm(),
          child: FittedBox(
            child: Text(
              'Get One Time Passcode',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
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
      suffixIcon: Container(
        height: 0,
        width: 0,
      ),
    );
  }
}
