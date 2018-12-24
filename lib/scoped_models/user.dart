import 'package:flutter_course/models/user.dart';
import 'package:flutter_course/scoped_models/connected_products.dart';

mixin UserModel on ConnectedProductsModel {
  void login(String email, String password) {
    authenticatedUser = User(id: 'adfadf', email: email, password: password);
  }
}
