import 'package:flutter/material.dart';
import 'package:flutter_course/pages/auth.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class MustLogin extends StatelessWidget {
  final Widget _targetWidget;

  MustLogin(this._targetWidget);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        if (model.user != null) {
          return _targetWidget;
        }

        return AuthPage();
      },
    );
  }
}
