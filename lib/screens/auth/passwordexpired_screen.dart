import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/screens/setup/setup_home_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:local_auth/local_auth.dart';

class PasswordExpiredScreen extends StatefulWidget {
  final Map<dynamic, dynamic> routeArgs;

  PasswordExpiredScreen({Key key, this.routeArgs}) : super(key: key);

  @override
  _PasswordExpiredScreenState createState() => _PasswordExpiredScreenState();
}

class _PasswordExpiredScreenState extends State<PasswordExpiredScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  final _formKey = GlobalKey<FormState>();

  String _password, _confirmPassword, _token = '';

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    if (widget.routeArgs != null) {
      _token = widget.routeArgs['token'];
    }

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

  void _loadInitData() async {
    if (_isInit) {
      // _usernameController.text = null;
      _confirmPasswordController.text = null;
      _passwordController.text = null;
    }
    setState(() {});
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Success'),
        content: Text(
          'Password Updated Successfully',
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (BuildContext context) => SetupHomeScreen(),
                    settings: const RouteSettings(name: routes.SetupHomeRoute),
                  ),
                  (Route<dynamic> route) => false);

              // return Navigator.of(context).pushReplacementNamed(
              //   routes.LoginRoute,
              // );
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

      setState(() {
        _isLoading = false;
      });

      final checkLogin = await Provider.of<AuthProvider>(context, listen: false)
          .updatePassword(password: _password, token: _token);

      if (checkLogin) {
        return _showSuccessDialog();
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
              width: 300,
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
