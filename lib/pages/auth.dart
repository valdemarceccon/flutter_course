import 'package:flutter/material.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => new _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
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
                    _buildPasswordTextField(),
                    _buildAcceptSwitch(),
                    SizedBox(
                      height: 10.0,
                    ),
                    ScopedModelDescendant<MainModel>(
                      builder: (context, child, model) {
                        return RaisedButton(
                          child: Text('Login'),
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).primaryColorLight,
                          onPressed: () => _submitForm(model),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm(MainModel model) {
    if (_formKey.currentState.validate() && _formData['termsAccepted']) {
      _formKey.currentState.save();
      model.login(_formData['email'], _formData['password']);
      Navigator.pushReplacementNamed(context, '/products');
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

  TextFormField _buildPasswordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
      ),
      onSaved: (value) => _formData['password'] = value,
      validator: _isEmptyValidator,
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

  String _isEmptyValidator(String value) {
    if (value.isEmpty) {
      return 'Password is required';
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
