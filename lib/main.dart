import 'package:flutter/material.dart';
import 'package:flutter_course/pages/product.dart';
import 'package:flutter_course/pages/products.dart';
import 'package:flutter_course/pages/products_admin.dart';
import 'package:flutter_course/scoped_models/main.dart';
import 'package:flutter_course/widgets/products/auth_guard.dart';
import 'package:scoped_model/scoped_model.dart';

main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _mainModel = MainModel();

  @override
  void initState() {
    super.initState();
    _mainModel.autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _mainModel,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.purple,
            buttonColor: Colors.deepPurple),
        routes: {
          '/': (BuildContext context) => MustLogin(ProductsPage(_mainModel)),
          '/admin': (BuildContext context) =>
              MustLogin(ProductsAdminPage(_mainModel)),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }

          if (pathElements[1] == 'product') {
            final String id = pathElements[2];
            return MaterialPageRoute<bool>(
                builder: (BuildContext context) => MustLogin(ProductPage(id)));
          }

          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  MustLogin(ProductsPage(_mainModel)));
        },
      ),
    );
  }
}
