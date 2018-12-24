import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/models/user.dart';
import 'package:scoped_model/scoped_model.dart';

mixin ConnectedProductsModel on Model {
  final Map<String, Product> products = {};
  User authenticatedUser;

  void addProduct(
      String title, String description, String image, double price) {
    final Product newProduct = Product(
        title: title,
        description: description,
        price: price,
        image: image,
        userEmail: authenticatedUser.email,
        userId: authenticatedUser.id);
    if (!products.containsKey(newProduct.title)) {
      products.addAll({newProduct.title: newProduct});
    }
  }
}
