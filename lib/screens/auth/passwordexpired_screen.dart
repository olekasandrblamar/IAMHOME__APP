import 'package:ceras/providers/auth_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:local_auth/local_auth.dart';

class PasswordExpiredScreen extends StatefulWidget {
  @override
  _PasswordExpiredScreenState createState() => _PasswordExpiredScreenState();
}

class _PasswordExpiredScreenState extends State<PasswordExpiredScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  final _formKey = GlobalKey<FormState>();

  String _password, _confirmPassword = '';

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  var _isInit = true;
  var _isLoading = false;

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
    _confirmPasswordController.dispose();
    _passwordController.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) {
      return;
    }

    var userId = await Provider.of<AuthProvider>(context, listen: false).userId;

    if (userId != null) {
      setState(() {
        _confirmPasswordController.text = userId;
      });
    }

    Future.delayed(Duration(milliseconds: 300), () async {
      var token = await Provider.of<AuthProvider>(context, listen: false)
          .tryAuthLogin();

      if (token) {
        var didAuthenticate = await auth.authenticateWithBiometrics(
          localizedReason: 'Please authenticate to show your data',
          useErrorDialogs: true,
          stickyAuth: true,
        );
        if (didAuthenticate) {
          //This code is to refresh the access token
          final accessToken =
              await Provider.of<AuthProvider>(context, listen: false).authToken;
          if (accessToken != null) {
            return Navigator.of(context).pushReplacementNamed(
              routes.DataRoute,
            );
          }
        }
      }
    });

    // if (accessToken == null) {
    //   //return _goToLogin();
    // }
  }

  void _loadInitData() async {
    if (_isInit) {
      // _usernameController.text = null;
      _confirmPasswordController.text = null;
      _passwordController.text = null;
    }
    setState(() {});
    _loadUserData();
    _isInit = false;
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
      setState(() {
        _isLoading = true;
      });

      final isValid = _formKey.currentState.validate();
      if (!isValid) {
        return;
      }
      _formKey.currentState.save();

// need to implement code here
      final checkLogin = null;

      // await Provider.of<AuthProvider>(context, listen: false)
      //     .validateAndLogin(
      //   email: _email,
      //   password: _password,
      // );

      if (checkLogin) {
        return Navigator.of(context).pushReplacementNamed(
          routes.DataRoute,
        );
      }
    } catch (error) {
      print(error);
      showErrorDialog(context, error.toString());
    }

    setState(() {
      _isLoading = false;
    });
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
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
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
                              // const SizedBox(height: 20),
                              // _nameInput(),
                              const SizedBox(height: 20),
                              _passwordInput(),
                              const SizedBox(height: 20),
                              _confirmPasswordInput(),
                              const SizedBox(height: 40),
                              _confirmButton(),
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
                  'Out With',
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
                  'The Old,',
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

  Widget _passwordInput() {
    return TextFormField(
      style: TextStyle(
        fontSize: 24,
      ),
      // suffixIcon: Icon(Icons.remove_red_eye),
      decoration: _inputDecoration('Create New Password', ''),
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      autofocus: false,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter password.';
        }

        if (value.length < 3) {
          return 'password must be more than 2 charater';
        }

        return null;
      },
      onSaved: (password) => _password = password,
      // onChanged: onChangePhoneNumberInput,
    );
  }

  Widget _confirmPasswordInput() {
    return TextFormField(
      style: TextStyle(
        fontSize: 24,
      ),
      // suffixIcon: Icon(Icons.remove_red_eye),
      decoration: _inputDecoration('Confirm New Password', ''),
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      autofocus: false,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter password.';
        }

        if (value != _passwordController.text) {
          return 'Not Match';
        }

        return null;
      },
      onSaved: (password) => _confirmPassword = password,
      // onChanged: onChangePhoneNumberInput,
    );
  }

  Widget _confirmButton() {
    return _isLoading
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
                child: Text(
                  'Confirm',
                ),
                onPressed: () => _saveForm(),
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
    );
  }
}
