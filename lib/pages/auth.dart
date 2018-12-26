import 'package:flutter/material.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';

enum _AuthMode { LOGIN, SIGN_UP }

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => new _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _passwordController = TextEditingController();
  _AuthMode _authMode = _AuthMode.LOGIN;

  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'termsAccepted': false
  };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * .95;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(image: _buildBackgroundImage()),
        padding: EdgeInsets.all(10.0),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: targetWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildEmailTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildPasswordTextField(_passwordController),
                    SizedBox(
                      height: 10.0,
                    ),
                    _authMode == _AuthMode.LOGIN
                        ? Container()
                        : _buildPasswordConfirmationTextField(
                        _passwordController),
                    _authMode == _AuthMode.LOGIN
                        ? Container()
                        : _buildAcceptSwitch(),
                    SizedBox(
                      height: 10.0,
                    ),
                    ScopedModelDescendant<MainModel>(
                      builder: (context, child, model) {
                        return model.isLoading
                            ? Center(
                          child: CircularProgressIndicator(),
                        )
                            : RaisedButton(
                          child: Text(_authMode == _AuthMode.LOGIN
                              ? 'Login'
                              : 'Sign up'),
                          color: Theme
                              .of(context)
                              .primaryColor,
                          textColor: Theme
                              .of(context)
                              .primaryColorLight,
                          onPressed: () => _submitForm(model),
                        );
                      },
                    ),
                    FlatButton(
                      child: Text(
                          'Switch to ${_authMode == _AuthMode.LOGIN
                              ? 'Sign up'
                              : 'Login'}'),
                      onPressed: () =>
                          setState(() {
                            _authMode = _authMode == _AuthMode.LOGIN
                                ? _AuthMode.SIGN_UP
                                : _AuthMode.LOGIN;
                          }),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateTerms() {
    if (_formData['termsAccepted'] || _authMode == _AuthMode.LOGIN) {
      return true;
    }
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Must accept terms'),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });

    return false;
  }

  void _submitForm(MainModel model) async {
    if (_formKey.currentState.validate() && _validateTerms()) {
      _formKey.currentState.save();

      Map<String, dynamic> authInfo;

      if (_authMode == _AuthMode.LOGIN) {
        authInfo = await model.login(_formData['email'], _formData['password']);
      } else {
        authInfo =
        await model.signup(_formData['email'], _formData['password']);
      }

      if (authInfo['success']) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('An error ocurred'),
                content: Text(authInfo['message']),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              );
            });
      }
    }
  }

  SwitchListTile _buildAcceptSwitch() {
    return SwitchListTile(
      value: _formData['termsAccepted'],
      onChanged: (value) => setState(() {
        _formData['termsAccepted'] = value;
      }),
      title: Text('Accept terms'),
    );
  }

  TextFormField _buildPasswordTextField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
      ),
      onSaved: (value) => _formData['password'] = value,
      validator: _passwordValidator,
    );
  }

  TextFormField _buildPasswordConfirmationTextField(
      TextEditingController controller) {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) =>
      value != controller.text ? 'Password does not match' : null,
    );
  }

  TextFormField _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'E-mail',
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) => _formData['email'] = value,
      validator: _isEmailValid,
    );
  }

  String _isEmailValid(String email) {
    var emailRegex =
    RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{"
    r"|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]"
    r"(?:[a-z0-9-]*[a-z0-9])?");

    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      return 'E-mail is invalid.';
    }

    return null;
  }

  String _passwordValidator(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password is too short. Enter at least 6 characters.';
    }
    return null;
  }

  DecorationImage _buildBackgroundImage() {
    return DecorationImage(
        colorFilter:
        ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
        fit: BoxFit.cover,
        image: AssetImage('assets/background.jpg'));
  }
}
