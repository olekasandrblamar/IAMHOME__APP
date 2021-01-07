import 'package:ceras/config/env.dart';
import 'package:ceras/models/promo_model.dart';
import 'package:ceras/providers/auth_provider.dart';
import 'package:ceras/providers/devices_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ceras/constants/route_paths.dart' as routes;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RedeemScreen extends StatefulWidget {
  @override
  _RedeemScreenState createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  final _formKey = GlobalKey<FormState>();

  String _code;
  bool _isLoading = false;
  String _redeemCode;

  final TextEditingController _codeController = TextEditingController();

  final FocusNode _codeFocusNode = FocusNode();

  @override
  void initState() {
    _loadRedeemCode();

    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();

    super.dispose();
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Invalid Code!'),
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

  void _showOkayDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Redeemed Code!',
          ),
          content: Text(
            _redeemCode,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Okay',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
        _isLoading = true;
      });

      final PromoModel promocode =
          await Provider.of<DevicesProvider>(context, listen: false)
              .redeemPromo(_code);

      if (promocode == null) {
        return;
      }

      if (promocode.environmentId == null) {
        return showErrorDialog(context, 'Please enter a valid code');
      }

      final prefs = await SharedPreferences.getInstance();
      // final redeemCode = await prefs.getString('redeemCode');

      await prefs.setString('redeemCode', _code);
      await prefs.setString('apiBaseUrl', promocode.dataUrl);
      await prefs.setString('authUrl', promocode.authUrl);

      setState(() {
        _redeemCode = _code;
      });

      _showOkayDialog();
    } catch (error) {
      print(error);
      showErrorDialog(context, error.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadRedeemCode() async {
    final prefs = await SharedPreferences.getInstance();
    final redeemCode = await prefs.getString('redeemCode');

    if (redeemCode != null) {
      setState(() {
        _redeemCode = redeemCode;
      });
    } else {
      setState(() {
        _redeemCode = null;
      });
    }
  }

  Future<void> _removeCode() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('redeemCode');
    await prefs.setString('apiBaseUrl', env.baseUrl);
    await prefs.setString('authUrl', env.authUrl);

    setState(() {
      _redeemCode = null;
    });

    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(color: Colors.black),
        backgroundColor: Color(0xffecf3fb),
        elevation: 0,
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
                          child: _redeemCode == null
                              ? Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    _codeInput(),
                                    const SizedBox(height: 40),
                                    _submitButton(),
                                  ],
                                )
                              : Column(
                                  children: [
                                    const SizedBox(height: 60),
                                    Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Container(
                                        width: 180.0,
                                        height: 60.0,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          color: Theme.of(context).primaryColor,
                                          textColor: Colors.white,
                                          child: Text(
                                            'Remove Code',
                                          ),
                                          onPressed: () => _removeCode(),
                                        ),
                                      ),
                                    )
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
                  _redeemCode == null ? 'Redeem' : 'Redeemed',
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
                  _redeemCode ?? 'Code',
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

  Widget _codeInput() {
    return TextFormField(
      style: TextStyle(
        fontSize: 24,
      ),
      decoration: _inputDecoration('Code', ''),
      controller: _codeController,
      focusNode: _codeFocusNode,
      textInputAction: TextInputAction.done,
      autofocus: false,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter code.';
        }

        return null;
      },
      onFieldSubmitted: (_) {},
      onSaved: (code) => _code = code,
      // onChanged: onChangePhoneNumberInput,
    );
  }

  Widget _submitButton() {
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
                  'Submit',
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
      suffixIcon: Container(
        height: 0,
        width: 0,
      ),
    );
  }
}
